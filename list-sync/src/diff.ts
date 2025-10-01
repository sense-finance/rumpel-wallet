import { Contract, JsonRpcProvider, Log } from 'ethers';
import { existsSync, readFileSync } from 'fs';
import { dirname, join } from 'path';
import { loadAllAllowlists, AllowlistNormalized, SelectorState } from './allowlist.js';
import { parse } from 'yaml';

const TRANSFER_SELECTOR = '0xa9059cbb';
const APPROVE_SELECTOR = '0x095ea7b3';
const ZERO_SELECTOR = '0x00000000';
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

interface ChainConfig {
  slug: string;
  chainId: number;
  rpcEnv: string;
  guard: string;
  module: string;
  tags: string[];
  startBlock: number;
  adminSafe: string;
}

interface ChainsFile {
  chains: ChainConfig[];
}

interface GuardDiffEntry {
  target: string;
  selector: string;
  desired?: SelectorState;
  actual?: SelectorState;
  signature?: string;
}

interface ModuleDiffEntry {
  target: string;
  selector: string;
  signature?: string;
}

export interface ChainDiffResult {
  chain: ChainConfig;
  guardMissing: GuardDiffEntry[];
  guardMismatched: GuardDiffEntry[];
  guardExtra: GuardDiffEntry[];
  moduleMissing: ModuleDiffEntry[];
  moduleExtra: ModuleDiffEntry[];
}

function normalizeAddress(address: string, context: string): string {
  if (!address.startsWith('0x') || address.length !== 42) {
    throw new Error(`Invalid address ${address} (${context})`);
  }
  return address.toLowerCase();
}

function normalizeSelector(selector: string, context: string): { selector: string; signature?: string } {
  if (!/^0x[0-9a-fA-F]{8}$/.test(selector)) {
    throw new Error(`Invalid selector ${selector} (${context})`);
  }
  return { selector: selector.toLowerCase() };
}

function loadChainsConfig(path: string): ChainConfig[] {
  const raw = parse(readFileSync(path, 'utf8')) as ChainsFile;
  if (!raw || !Array.isArray(raw.chains)) {
    throw new Error('chains.yaml missing chains array');
  }
  return raw.chains.map((chain) => ({
    ...chain,
    guard: normalizeAddress(chain.guard, `${chain.slug} guard`),
    module: normalizeAddress(chain.module, `${chain.slug} module`),
    startBlock: chain.startBlock ?? 0,
    adminSafe: normalizeAddress(chain.adminSafe, `${chain.slug} adminSafe`),
    tags: chain.tags.slice(),
  }));
}

function buildAllowlistIndex(dir: string): Map<string, AllowlistNormalized> {
  const all = loadAllAllowlists(dir);
  const index = new Map<string, AllowlistNormalized>();
  for (const entry of all) {
    if (index.has(entry.slug)) {
      throw new Error(`Duplicate allowlist slug ${entry.slug}`);
    }
    index.set(entry.slug, entry);
  }
  return index;
}

interface GuardStateInfo {
  state: SelectorState;
  signature?: string;
}

interface ModuleStateInfo {
  signature?: string;
}

type GuardStateMap = Map<string, Map<string, GuardStateInfo>>;
type ModuleStateMap = Map<string, Map<string, ModuleStateInfo>>;

function setGuardState(map: GuardStateMap, target: string, selector: string, info: GuardStateInfo): void {
  if (!map.has(target)) {
    map.set(target, new Map());
  }
  map.get(target)!.set(selector, info);
}

function addModuleBlock(map: ModuleStateMap, target: string, selector: string, info: ModuleStateInfo): void {
  if (!map.has(target)) {
    map.set(target, new Map());
  }
  map.get(target)!.set(selector, info);
}

function computeDesiredStates(chain: ChainConfig, allowlists: Map<string, AllowlistNormalized>): {
  guard: GuardStateMap;
  module: ModuleStateMap;
} {
  const guard: GuardStateMap = new Map();
  const module: ModuleStateMap = new Map();

  for (const tag of chain.tags) {
    const allowlist = allowlists.get(tag);
    if (!allowlist) {
      throw new Error(`No allowlist data for tag ${tag}`);
    }

    for (const call of allowlist.guard.calls) {
      setGuardState(guard, call.target, call.selector, { state: call.state, signature: call.signature });
    }

    for (const token of allowlist.guard.tokens) {
      setGuardState(guard, token.token, TRANSFER_SELECTOR, { state: token.transfer });
      setGuardState(guard, token.token, APPROVE_SELECTOR, { state: token.approve });
    }

    for (const block of allowlist.module.blocks) {
      addModuleBlock(module, block.target, block.selector, { signature: block.signature });
    }

    for (const token of allowlist.module.tokens) {
      if (token.transfer) {
        addModuleBlock(module, token.token, TRANSFER_SELECTOR, {});
      }
      if (token.approve) {
        addModuleBlock(module, token.token, APPROVE_SELECTOR, {});
      }
    }
  }

  return { guard, module };
}

const GUARD_ABI = ['function allowedCalls(address target, bytes4 selector) view returns (uint8)'];
const MODULE_ABI = ['function blockedModuleCalls(address target, bytes4 selector) view returns (bool)'];

function mapGuardState(value: number): SelectorState {
  if (value === 0) return 'OFF';
  if (value === 1) return 'ON';
  if (value === 2) return 'PERMANENTLY_ON';
  throw new Error(`Unknown guard allow state ${value}`);
}

async function fetchGuardState(
  provider: JsonRpcProvider,
  chain: ChainConfig,
  desired: GuardStateMap,
): Promise<GuardStateMap> {
  const contract = new Contract(chain.guard, GUARD_ABI, provider);
  const pairs: Array<{ target: string; selector: string }> = [];
  for (const [target, selectors] of desired.entries()) {
    for (const selector of selectors.keys()) {
      pairs.push({ target, selector });
    }
  }

  const result: GuardStateMap = new Map();
  const batchSize = 50;
  for (let i = 0; i < pairs.length; i += batchSize) {
    const slice = pairs.slice(i, i + batchSize);
    const responses = await Promise.all(
      slice.map(({ target, selector }) => contract.allowedCalls(target, selector))
    );
    responses.forEach((value, index) => {
      const { target, selector } = slice[index];
      setGuardState(result, target, selector, { state: mapGuardState(Number(value)) });
    });
  }

  return result;
}

async function fetchModuleState(
  provider: JsonRpcProvider,
  chain: ChainConfig,
  desired: ModuleStateMap,
): Promise<ModuleStateMap> {
  const contract = new Contract(chain.module, MODULE_ABI, provider);
  const pairs: Array<{ target: string; selector: string }> = [];
  for (const [target, selectors] of desired.entries()) {
    for (const selector of selectors.keys()) {
      pairs.push({ target, selector });
    }
  }

  const result: ModuleStateMap = new Map();
  const batchSize = 50;
  for (let i = 0; i < pairs.length; i += batchSize) {
    const slice = pairs.slice(i, i + batchSize);
    const responses = await Promise.all(
      slice.map(({ target, selector }) => contract.blockedModuleCalls(target, selector))
    );
    responses.forEach((value, index) => {
      if (value) {
        const { target, selector } = slice[index];
        addModuleBlock(result, target, selector, {});
      }
    });
  }

  return result;
}

function diffGuardStates(desired: GuardStateMap, actual: GuardStateMap): {
  missing: GuardDiffEntry[];
  mismatched: GuardDiffEntry[];
  extra: GuardDiffEntry[];
} {
  const missing: GuardDiffEntry[] = [];
  const mismatched: GuardDiffEntry[] = [];
  const extra: GuardDiffEntry[] = [];

  for (const [target, selectors] of desired.entries()) {
    for (const [selector, desiredInfo] of selectors.entries()) {
      const actualInfo = actual.get(target)?.get(selector);
      const actualState = actualInfo?.state ?? 'OFF';
      const desiredState = desiredInfo.state;
      if (actualState === desiredState) {
        continue;
      }
      if (actualState === 'OFF') {
        missing.push({ target, selector, desired: desiredState, signature: desiredInfo.signature });
      } else if (desiredState === 'OFF') {
        extra.push({ target, selector, actual: actualState, desired: desiredState, signature: desiredInfo.signature });
      } else {
        mismatched.push({ target, selector, desired: desiredState, actual: actualState, signature: desiredInfo.signature });
      }
    }
  }

  for (const [target, selectors] of actual.entries()) {
    for (const [selector, actualInfo] of selectors.entries()) {
      if (actualInfo.state === 'OFF') continue;
      const desiredInfo = desired.get(target)?.get(selector);
      const desiredState = desiredInfo?.state ?? 'OFF';
      if (desiredState === 'OFF') {
        extra.push({ target, selector, actual: actualInfo.state, desired: desiredState, signature: desiredInfo?.signature });
      }
    }
  }

  return { missing, mismatched, extra };
}

function diffModuleStates(desired: ModuleStateMap, actual: ModuleStateMap): {
  missing: ModuleDiffEntry[];
  extra: ModuleDiffEntry[];
} {
  const missing: ModuleDiffEntry[] = [];
  const extra: ModuleDiffEntry[] = [];

  for (const [target, selectors] of desired.entries()) {
    for (const [selector, info] of selectors.entries()) {
      if (!actual.get(target)?.get(selector)) {
        missing.push({ target, selector, signature: info.signature });
      }
    }
  }

  for (const [target, selectors] of actual.entries()) {
    for (const [selector, info] of selectors.entries()) {
      if (!desired.get(target)?.get(selector)) {
        extra.push({ target, selector, signature: info.signature });
      }
    }
  }

  return { missing, extra };
}

function createProvider(chain: ChainConfig): JsonRpcProvider {
  const rpcUrl = process.env[chain.rpcEnv];
  if (!rpcUrl) {
    throw new Error(`Missing RPC URL env var ${chain.rpcEnv} for chain ${chain.slug}`);
  }
  return new JsonRpcProvider(rpcUrl, chain.chainId);
}


export async function diffChains(): Promise<ChainDiffResult[]> {
  const root = findRepoRoot();
  const chains = loadChainsConfig(join(root, 'list-sync', 'chains.yaml'));
  const allowlists = buildAllowlistIndex(join(root, 'list-sync', 'tags'));
  const results: ChainDiffResult[] = [];

  for (const chain of chains) {
    const provider = createProvider(chain);
    const desired = computeDesiredStates(chain, allowlists);
    const actualGuard = await fetchGuardState(provider, chain, desired.guard);
    const actualModule = await fetchModuleState(provider, chain, desired.module);
    const extrasGuard = await fetchGuardStateFromEvents(provider, chain, desired.guard);
    const extrasModule = await fetchModuleStateFromEvents(provider, chain, desired.module);

    const guardDiff = diffGuardStates(desired.guard, actualGuard);
    const moduleDiff = diffModuleStates(desired.module, actualModule);

    // Merge extras detected via events
    extrasGuard.extra.forEach((entry) => guardDiff.extra.push(entry));
    extrasModule.extra.forEach((entry) => moduleDiff.extra.push(entry));

    guardDiff.missing = dedupeGuardEntries(guardDiff.missing);
    guardDiff.mismatched = dedupeGuardEntries(guardDiff.mismatched);
    guardDiff.extra = dedupeGuardEntries(guardDiff.extra);
    moduleDiff.missing = dedupeModuleEntries(moduleDiff.missing);
    moduleDiff.extra = dedupeModuleEntries(moduleDiff.extra);

    results.push({
      chain,
      guardMissing: guardDiff.missing,
      guardMismatched: guardDiff.mismatched,
      guardExtra: guardDiff.extra,
      moduleMissing: moduleDiff.missing,
      moduleExtra: moduleDiff.extra,
    });
  }

  return results;
}

function dedupeGuardEntries(entries: GuardDiffEntry[]): GuardDiffEntry[] {
  const map = new Map<string, GuardDiffEntry>();
  for (const entry of entries) {
    const key = `${entry.target}.${entry.selector}`;
    const existing = map.get(key);
    if (!existing || (!existing.signature && entry.signature)) {
      map.set(key, entry);
    }
  }
  return Array.from(map.values());
}

function dedupeModuleEntries(entries: ModuleDiffEntry[]): ModuleDiffEntry[] {
  const map = new Map<string, ModuleDiffEntry>();
  for (const entry of entries) {
    const key = `${entry.target}.${entry.selector}`;
    const existing = map.get(key);
    if (!existing || (!existing.signature && entry.signature)) {
      map.set(key, entry);
    }
  }
  return Array.from(map.values());
}

async function fetchGuardStateFromEvents(
  provider: JsonRpcProvider,
  chain: ChainConfig,
  desired: GuardStateMap,
) {
  const logs = await fetchLogs(provider, chain.guard, GUARD_EVENT_TOPIC, chain.startBlock);
  const actual: GuardStateMap = new Map();

  logs
    .sort((a, b) => (a.blockNumber === b.blockNumber ? a.index - b.index : a.blockNumber - b.blockNumber))
    .forEach((log) => {
      const targetHex = `0x${log.topics[1].slice(-40)}`;
      const selectorHex = `0x${log.topics[2].slice(-8)}`;
      const target = normalizeAddress(targetHex, 'guard event target');
      const selectorInfo = normalizeSelector(selectorHex, 'guard event selector');
      const selector = selectorInfo.selector;
      if (selector === ZERO_SELECTOR || target === ZERO_ADDRESS) {
        return;
      }
      const state = mapGuardState(Number(BigInt(log.data)));
      setGuardState(actual, target, selector, { state, signature: selectorInfo.signature });
    });

  const extra: GuardDiffEntry[] = [];
  for (const [target, selectors] of actual.entries()) {
    for (const [selector, info] of selectors.entries()) {
      if (info.state === 'OFF' || selector === ZERO_SELECTOR || target === ZERO_ADDRESS) continue;
      const desiredInfo = desired.get(target)?.get(selector);
      const desiredState = desiredInfo?.state ?? 'OFF';
      if (desiredState === 'OFF') {
        extra.push({ target, selector, actual: info.state, desired: desiredState, signature: desiredInfo?.signature });
      }
    }
  }

  return { actual, extra };
}

async function fetchModuleStateFromEvents(
  provider: JsonRpcProvider,
  chain: ChainConfig,
  desired: ModuleStateMap,
) {
  const logs = await fetchLogs(provider, chain.module, MODULE_EVENT_TOPIC, chain.startBlock);
  const actual: ModuleStateMap = new Map();

  logs.forEach((log) => {
    const targetHex = `0x${log.topics[1].slice(-40)}`;
    const selectorHex = `0x${log.topics[2].slice(-8)}`;
    const target = normalizeAddress(targetHex, 'module event target');
    const selectorInfo = normalizeSelector(selectorHex, 'module event selector');
    const selector = selectorInfo.selector;
    if (selector === ZERO_SELECTOR || target === ZERO_ADDRESS) {
      return;
    }
    addModuleBlock(actual, target, selector, { signature: selectorInfo.signature });
  });

  const extra: ModuleDiffEntry[] = [];
  for (const [target, selectors] of actual.entries()) {
    for (const [selector, info] of selectors.entries()) {
      if (selector === ZERO_SELECTOR || target === ZERO_ADDRESS) {
        continue;
      }
      if (!desired.get(target)?.get(selector)) {
        extra.push({ target, selector, signature: info.signature });
      }
    }
  }

  return { actual, extra };
}

const GUARD_EVENT_TOPIC = '0x70785a9b51e0166fb561479b514223d6b27cc81df3c02b16292211b860842f73';
const MODULE_EVENT_TOPIC = '0xbd2ecf3a575dfdb98cf6475d8c68efb6cdcce886ac9db5f29a9fdc1b17cc3c88';

async function fetchLogs(
  provider: JsonRpcProvider,
  address: string,
  topic: string,
  startBlock: number,
): Promise<Log[]> {
  const latest = await provider.getBlockNumber();
  const batchSize = 5_000;
  const ranges: Array<{ from: number; to: number }> = [];

  let from = startBlock;
  while (from <= latest) {
    const to = Math.min(from + batchSize - 1, latest);
    ranges.push({ from, to });
    from = to + 1;
  }

  const concurrency = 8;
  const logs: Log[] = [];
  for (let i = 0; i < ranges.length; i += concurrency) {
    const slice = ranges.slice(i, i + concurrency);
    const segments = await Promise.all(
      slice.map((range) => provider.getLogs({ address, fromBlock: range.from, toBlock: range.to, topics: [topic] })),
    );
    for (const segment of segments) {
      logs.push(...segment);
    }
  }

  return logs;
}

function findRepoRoot(): string {
  let dir = process.cwd();
  while (true) {
    const candidate = join(dir, 'list-sync', 'chains.yaml');
    if (existsSync(candidate)) {
      return dir;
    }
    const parent = dirname(dir);
    if (parent === dir) {
      throw new Error('Could not locate repository root (missing list-sync/chains.yaml)');
    }
    dir = parent;
  }
}
