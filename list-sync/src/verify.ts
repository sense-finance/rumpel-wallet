import { readFileSync, existsSync } from 'fs';
import { join, dirname } from 'path';
import { FlattenedRecord, flattenAllowlist, loadAllAllowlists, SelectorState } from './allowlist.js';

const ROOT = findRepoRoot();
const SNAPSHOT_PATH = join(ROOT, 'tmp', 'rumpel_config_dump.jsonl');
const TAG_DIR = join(ROOT, 'list-sync', 'tags');

type SnapshotRecord = {
  tag: string;
  kind: 'guard.protocol' | 'guard.token' | 'module.protocol' | 'module.token';
  target?: string;
  token?: string;
  selector?: string;
  state?: string;
  transferState?: string;
  approveState?: string;
  blockTransfer?: string;
  blockApprove?: string;
};

function toSelectorState(value: string | undefined, context: string): SelectorState {
  if (!value) {
    throw new Error(`Missing selector state for ${context}`);
  }
  const upper = value.toUpperCase();
  if (upper === 'OFF' || upper === 'ON' || upper === 'PERMANENTLY_ON') {
    return upper;
  }
  throw new Error(`Unexpected selector state ${value} (${context})`);
}

function toBoolean(value: string | undefined): boolean {
  return value === 'true';
}

function normalizeSnapshotRecord(rec: SnapshotRecord): FlattenedRecord {
  switch (rec.kind) {
    case 'guard.protocol':
      return {
        slug: rec.tag,
        kind: 'guard.call',
        target: rec.target?.toLowerCase(),
        selector: rec.selector?.toLowerCase(),
        state: toSelectorState(rec.state, `${rec.tag} guard.protocol`),
      };
    case 'guard.token':
      return {
        slug: rec.tag,
        kind: 'guard.token',
        token: rec.token?.toLowerCase(),
        transferState: toSelectorState(rec.transferState, `${rec.tag} guard.token transfer`),
        approveState: toSelectorState(rec.approveState, `${rec.tag} guard.token approve`),
      };
    case 'module.protocol':
      return {
        slug: rec.tag,
        kind: 'module.call',
        target: rec.target?.toLowerCase(),
        selector: rec.selector?.toLowerCase(),
      };
    case 'module.token':
      return {
        slug: rec.tag,
        kind: 'module.token',
        token: rec.token?.toLowerCase(),
        blockTransfer: toBoolean(rec.blockTransfer),
        blockApprove: toBoolean(rec.blockApprove),
      };
    default:
      throw new Error(`Unknown snapshot kind ${(rec as SnapshotRecord).kind}`);
  }
}

function canonicalize(record: FlattenedRecord): string {
  const parts = [record.slug, record.kind];
  if (record.target) parts.push(record.target);
  if (record.token) parts.push(record.token);
  if (record.selector) parts.push(record.selector);
  if (record.state) parts.push(record.state);
  if (record.transferState) parts.push(`transfer:${record.transferState}`);
  if (record.approveState) parts.push(`approve:${record.approveState}`);
  if (record.blockTransfer !== undefined) parts.push(`blockTransfer:${record.blockTransfer}`);
  if (record.blockApprove !== undefined) parts.push(`blockApprove:${record.blockApprove}`);
  return parts.join('|');
}

function loadSnapshot(path: string): FlattenedRecord[] {
  const raw = readFileSync(path, 'utf8');
  const lines = raw.split('\n').map((line) => line.trim()).filter(Boolean);
  const records = lines.map((line) => JSON.parse(line) as SnapshotRecord);
  return records.map((rec) => normalizeSnapshotRecord(rec));
}

function loadYamlRecords(): FlattenedRecord[] {
  const allowlists = loadAllAllowlists(TAG_DIR);
  return allowlists.flatMap((entry) => flattenAllowlist(entry));
}

function diffSets(expected: string[], actual: string[]): { missing: string[]; extra: string[] } {
  const expectedSet = new Set(expected);
  const actualSet = new Set(actual);
  const missing = expected.filter((item) => !actualSet.has(item));
  const extra = actual.filter((item) => !expectedSet.has(item));
  return { missing, extra };
}

export function verifySnapshotMatchesYaml(): void {
  const snapshotRecords = loadSnapshot(SNAPSHOT_PATH).map(canonicalize).sort();
  const yamlRecords = loadYamlRecords().map(canonicalize).sort();

  const { missing, extra } = diffSets(snapshotRecords, yamlRecords);
  if (missing.length > 0 || extra.length > 0) {
    const messages = [] as string[];
    if (missing.length > 0) {
      messages.push('Missing entries:\n' + missing.join('\n'));
    }
    if (extra.length > 0) {
      messages.push('Extra entries:\n' + extra.join('\n'));
    }
    throw new Error(messages.join('\n\n'));
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  verifySnapshotMatchesYaml();
  // eslint-disable-next-line no-console
  console.log('Allowlist YAML matches snapshot.');
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
