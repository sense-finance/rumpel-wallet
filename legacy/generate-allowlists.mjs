import { readFileSync, writeFileSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const LEGACY_DIR = dirname(fileURLToPath(import.meta.url));
const ROOT = dirname(LEGACY_DIR);
const INPUT = join(LEGACY_DIR, 'rumpel_config_dump.jsonl');
const OUTPUT_DIR = join(ROOT, 'list-sync', 'tags');

function ensureDir(path) {
  mkdirSync(path, { recursive: true });
}

function parseLines(path) {
  const text = readFileSync(path, 'utf8');
  const lines = text.split('\n').map((line) => line.trim()).filter(Boolean);
  return lines.map((line) => JSON.parse(line));
}

function groupRecords(records) {
  const tags = new Map();

  for (const record of records) {
    const tag = record.tag;
    if (!tags.has(tag)) {
      tags.set(tag, {
        guard: {
          allow: new Map(),
          tokens: new Map(),
        },
        module: {
          block: new Map(),
          tokens: new Map(),
        },
      });
    }
    const entry = tags.get(tag);

    if (record.kind === 'guard.protocol') {
      const byTarget = entry.guard.allow;
      if (!byTarget.has(record.target)) {
        byTarget.set(record.target, []);
      }
      byTarget.get(record.target).push({ selector: record.selector, state: record.state });
    } else if (record.kind === 'guard.token') {
      entry.guard.tokens.set(record.token, {
        transfer: record.transferState,
        approve: record.approveState,
      });
    } else if (record.kind === 'module.protocol') {
      const byTarget = entry.module.block;
      if (!byTarget.has(record.target)) {
        byTarget.set(record.target, new Set());
      }
      byTarget.get(record.target).add(record.selector);
    } else if (record.kind === 'module.token') {
      entry.module.tokens.set(record.token, {
        blockTransfer: record.blockTransfer === 'true',
        blockApprove: record.blockApprove === 'true',
      });
    } else {
      throw new Error(`Unknown kind: ${record.kind}`);
    }
  }

  return tags;
}

function sortKeys(iterable) {
  return Array.from(iterable).sort((a, b) => {
    if (a < b) return -1;
    if (a > b) return 1;
    return 0;
  });
}

function emitYaml(tag, data) {
  const lines = [];
  lines.push(`slug: ${tag}`);

  if (data.guard.allow.size > 0 || data.guard.tokens.size > 0) {
    lines.push('guard:');

    if (data.guard.allow.size > 0) {
      lines.push('  allow:');
      const targets = sortKeys(data.guard.allow.keys());
      for (const target of targets) {
        lines.push(`    - target: "${target}"`);
        const selectors = data.guard.allow.get(target)
          .slice()
          .sort((a, b) => (a.selector < b.selector ? -1 : a.selector > b.selector ? 1 : 0));
        lines.push('      selectors:');
        for (const sel of selectors) {
          lines.push('        - selector: "' + sel.selector + '"');
          lines.push('          state: "' + sel.state + '"');
        }
      }
    }

    if (data.guard.tokens.size > 0) {
      lines.push('  tokens:');
      const tokens = sortKeys(data.guard.tokens.keys());
      for (const token of tokens) {
        const cfg = data.guard.tokens.get(token);
        lines.push(`    - token: "${token}"`);
        lines.push(`      transfer: "${cfg.transfer}"`);
        lines.push(`      approve: "${cfg.approve}"`);
      }
    }
  }

  if (data.module.block.size > 0 || data.module.tokens.size > 0) {
    lines.push('module:');

    if (data.module.block.size > 0) {
      lines.push('  block:');
      const targets = sortKeys(data.module.block.keys());
      for (const target of targets) {
        lines.push(`    - target: "${target}"`);
        const selectors = sortKeys(data.module.block.get(target).values());
        lines.push('      selectors:');
        for (const selector of selectors) {
          lines.push(`        - "${selector}"`);
        }
      }
    }

    if (data.module.tokens.size > 0) {
      lines.push('  tokens:');
      const tokens = sortKeys(data.module.tokens.keys());
      for (const token of tokens) {
        const cfg = data.module.tokens.get(token);
        lines.push(`    - token: "${token}"`);
        lines.push(`      transfer: ${cfg.blockTransfer}`);
        lines.push(`      approve: ${cfg.blockApprove}`);
      }
    }
  }

  lines.push('');
  return lines.join('\n');
}

function writeYamlFiles(groups) {
  ensureDir(OUTPUT_DIR);

  for (const [tag, data] of groups) {
    const yaml = emitYaml(tag, data);
    const outputPath = join(OUTPUT_DIR, `${tag}.yaml`);
    ensureDir(dirname(outputPath));
    writeFileSync(outputPath, yaml, 'utf8');
  }
}

function main() {
  const records = parseLines(INPUT);
  const groups = groupRecords(records);
  writeYamlFiles(groups);
}

main();
