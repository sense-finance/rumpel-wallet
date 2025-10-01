#!/usr/bin/env node
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { Contract, Interface, JsonRpcProvider } from 'ethers';
import { dirname, join } from 'path';
import { loadAllowlistFile } from './allowlist.js';
import { parse } from 'yaml';

const TRANSFER_SELECTOR = '0xa9059cbb';
const APPROVE_SELECTOR = '0x095ea7b3';
const GUARD_SET_IFACE = new Interface(['function setCallAllowed(address target, bytes4 selector, uint8 state)']);
const MODULE_ADD_IFACE = new Interface(['function addBlockedModuleCall(address target, bytes4 selector)']);

interface ChainConfig {
  slug: string;
  slugLower: string;
  chainId: number;
  rpcEnv: string;
  guard: string;
  module: string;
  adminSafe: string;
  tags: string[];
}

interface Args {
  tag: string;
  chains?: string[];
  outDir: string;
  dryRun: boolean;
  help: boolean;
}

interface Action {
  to: string;
  data: string;
  description: string;
}

interface Plan {
  chain: ChainConfig;
  tag: string;
  actions: Action[];
}

(async () => {
  const args = parseArgs();
  if (args.help) {
    printHelp();
    return;
  }

  const root = findRepoRoot();
  const chains = loadChains(join(root, 'list-sync', 'chains.yaml'));
  const allowlistPath = join(root, 'list-sync', 'tags', `${args.tag}.yaml`);
  if (!existsSync(allowlistPath)) {
    throw new Error(`Allowlist ${args.tag} not found`);
  }
  const allowlist = loadAllowlistFile(allowlistPath);
  const tagKey = args.tag.toLowerCase();

  const selected = chains.filter((chain) => {
    if (!chain.tags.includes(tagKey)) return false;
    if (!args.chains) return true;
    return args.chains.includes(chain.slugLower);
  });

  if (selected.length === 0) {
    throw new Error(`Tag ${args.tag} not listed on any selected chain`);
  }

  const plans: Plan[] = [];
  for (const chain of selected) {
    const provider = createProvider(chain);
    const plan = await buildPlan(chain, allowlist.slug, allowlist, provider);
    plans.push(plan);
  }

  if (args.dryRun) {
    for (const plan of plans) {
      console.log(`Chain ${plan.chain.slug} (chainId ${plan.chain.chainId})`);
      if (plan.actions.length === 0) {
        console.log('  nothing to do');
        continue;
      }
      for (const action of plan.actions) {
        console.log(`  - ${action.description}`);
      }
    }
    return;
  }

  const outDir = join(root, args.outDir);
  mkdirSync(outDir, { recursive: true });
  for (const plan of plans) {
    if (plan.actions.length === 0) {
      console.log(`No actions for ${plan.chain.slug}; skipping file.`);
      continue;
    }
    const payload = buildSafeJson(plan);
    const filename = `${plan.tag}-${plan.chain.slug}.json`;
    const path = join(outDir, filename);
    writeFileSync(path, JSON.stringify(payload, null, 2));
    console.log(`Wrote ${path} (${plan.actions.length} actions)`);
  }
})();

function parseArgs(): Args {
  const args: Args = { tag: '', outDir: 'safe-batches', dryRun: false, help: false };
  const input = process.argv.slice(2);
  for (let i = 0; i < input.length; i++) {
    const arg = input[i];
    switch (arg) {
      case '--tag':
        args.tag = String(input[++i] ?? '');
        break;
      case '--chain':
        args.chains = String(input[++i] ?? '')
          .split(',')
          .map((c) => c.trim().toLowerCase())
          .filter(Boolean);
        break;
      case '--out-dir':
        args.outDir = String(input[++i] ?? 'safe-batches');
        break;
      case '--dry-run':
        args.dryRun = true;
        break;
      case '--help':
      case '-h':
        args.help = true;
        break;
      default:
        if (!args.tag && !arg.startsWith('--')) {
          args.tag = arg;
        }
        break;
    }
  }
  if (!args.tag && !args.help) {
    throw new Error('Missing required --tag argument');
  }
  return args;
}

function printHelp(): void {
  console.log(`Usage: node list-sync/dist/sync.js --tag <slug> [--chain ethereum,hyperEVM] [--dry-run]

Examples:
  node list-sync/dist/sync.js --tag cap-money-expansion-sep-15 --dry-run
  node list-sync/dist/sync.js --tag cap-money-expansion-sep-15
`);
}

function loadChains(path: string): ChainConfig[] {
  const raw = parse(readFileSync(path, 'utf8')) as { chains: ChainConfig[] };
  if (!raw?.chains) throw new Error('chains.yaml missing chains array');
  return raw.chains.map((chain) => ({
    slug: chain.slug,
    slugLower: chain.slug.toLowerCase(),
    chainId: chain.chainId,
    rpcEnv: chain.rpcEnv,
    guard: chain.guard.toLowerCase(),
    module: chain.module.toLowerCase(),
    adminSafe: chain.adminSafe.toLowerCase(),
    tags: chain.tags.map((tag) => tag.toLowerCase()),
  }));
}

async function buildPlan(
  chain: ChainConfig,
  tag: string,
  allowlist: ReturnType<typeof loadAllowlistFile>,
  provider: JsonRpcProvider,
): Promise<Plan> {
  const actions: Action[] = [];
  const guardQuery = new Contract(chain.guard, ['function allowedCalls(address,bytes4) view returns (uint8)'], provider);
  const moduleQuery = new Contract(chain.module, ['function blockedModuleCalls(address,bytes4) view returns (bool)'], provider);

  for (const call of allowlist.guard.calls) {
    const selector = call.selector;
    const target = call.target;
    const current = mapState(Number(await guardQuery.allowedCalls(target, selector)));
    if (current === call.state) continue;
    if (current === 'OFF' && call.state === 'PERMANENTLY_ON') {
      throw new Error(`Cannot escalate ${target}.${selector} from OFF to PERMANENTLY_ON on ${chain.slug}`);
    }
    if (current === 'PERMANENTLY_ON' && call.state !== 'PERMANENTLY_ON') {
      throw new Error(`Cannot downgrade permanently allowed call ${target}.${selector} on ${chain.slug}`);
    }
    const selectorLabel = call.signature ? `${selector} (${call.signature})` : selector;
    actions.push({
      to: chain.guard,
      data: GUARD_SET_IFACE.encodeFunctionData('setCallAllowed', [target, selector, stateToNumber(call.state)]),
      description: `guard ${target}.${selectorLabel} -> ${call.state}`,
    });
  }

  for (const token of allowlist.guard.tokens) {
    const addr = token.token;
    const transferState = mapState(Number(await guardQuery.allowedCalls(addr, TRANSFER_SELECTOR)));
    if (transferState !== token.transfer) {
      if (transferState === 'PERMANENTLY_ON' && token.transfer !== 'PERMANENTLY_ON') {
        throw new Error(`Cannot downgrade permanently allowed transfer for ${addr} on ${chain.slug}`);
      }
      actions.push({
        to: chain.guard,
        data: GUARD_SET_IFACE.encodeFunctionData('setCallAllowed', [addr, TRANSFER_SELECTOR, stateToNumber(token.transfer)]),
        description: `guard ${addr}.transfer -> ${token.transfer}`,
      });
    }

    const approveState = mapState(Number(await guardQuery.allowedCalls(addr, APPROVE_SELECTOR)));
    if (approveState !== token.approve) {
      if (approveState === 'PERMANENTLY_ON' && token.approve !== 'PERMANENTLY_ON') {
        throw new Error(`Cannot downgrade permanently allowed approve for ${addr} on ${chain.slug}`);
      }
      actions.push({
        to: chain.guard,
        data: GUARD_SET_IFACE.encodeFunctionData('setCallAllowed', [addr, APPROVE_SELECTOR, stateToNumber(token.approve)]),
        description: `guard ${addr}.approve -> ${token.approve}`,
      });
    }
  }

  for (const block of allowlist.module.blocks) {
    const blocked = await moduleQuery.blockedModuleCalls(block.target, block.selector);
    if (blocked) continue;
      const selectorLabel = block.signature ? `${block.selector} (${block.signature})` : block.selector;
      actions.push({
        to: chain.module,
        data: MODULE_ADD_IFACE.encodeFunctionData('addBlockedModuleCall', [block.target, block.selector]),
        description: `module block ${block.target}.${selectorLabel}`,
      });
  }

  for (const token of allowlist.module.tokens) {
    if (token.transfer) {
      const blocked = await moduleQuery.blockedModuleCalls(token.token, TRANSFER_SELECTOR);
      if (!blocked) {
        actions.push({
          to: chain.module,
          data: MODULE_ADD_IFACE.encodeFunctionData('addBlockedModuleCall', [token.token, TRANSFER_SELECTOR]),
          description: `module block ${token.token}.transfer`,
        });
      }
    }
    if (token.approve) {
      const blocked = await moduleQuery.blockedModuleCalls(token.token, APPROVE_SELECTOR);
      if (!blocked) {
        actions.push({
          to: chain.module,
          data: MODULE_ADD_IFACE.encodeFunctionData('addBlockedModuleCall', [token.token, APPROVE_SELECTOR]),
          description: `module block ${token.token}.approve`,
        });
      }
    }
  }

  return { chain, tag, actions };
}

function buildSafeJson(plan: Plan) {
  const createdAt = Date.now();
  return {
    version: '1.0',
    chainId: String(plan.chain.chainId),
    createdAt,
    meta: {
      name: 'Transactions Batch',
      description: `${plan.tag} (${plan.chain.slug})`,
      txBuilderVersion: '1.10.0',
      createdFromSafeAddress: plan.chain.adminSafe,
      createdFromOwnerAddress: '',
      checksum: null,
    },
    transactions: plan.actions.map((action) => ({
      to: action.to,
      value: '0x0',
      data: action.data,
    })),
  };
}

function mapState(value: number): 'OFF' | 'ON' | 'PERMANENTLY_ON' {
  if (value === 0) return 'OFF';
  if (value === 1) return 'ON';
  if (value === 2) return 'PERMANENTLY_ON';
  throw new Error(`Unknown guard state ${value}`);
}

function stateToNumber(state: string): number {
  if (state === 'OFF') return 0;
  if (state === 'ON') return 1;
  if (state === 'PERMANENTLY_ON') return 2;
  throw new Error(`Invalid allowlist state ${state}`);
}

function createProvider(chain: ChainConfig): JsonRpcProvider {
  const rpcUrl = process.env[chain.rpcEnv];
  if (!rpcUrl) {
    throw new Error(`Missing RPC URL env var ${chain.rpcEnv}`);
  }
  return new JsonRpcProvider(rpcUrl, chain.chainId);
}

function findRepoRoot(): string {
  let dir = process.cwd();
  while (true) {
    const candidate = join(dir, 'list-sync', 'chains.yaml');
    if (existsSync(candidate)) return dir;
    const parent = dirname(dir);
    if (parent === dir) {
      throw new Error('Could not locate repository root (missing list-sync/chains.yaml)');
    }
    dir = parent;
  }
}
