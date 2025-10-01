#!/usr/bin/env node
import { diffChains } from './diff.js';
function formatGuard(entry) {
    const selectorLabel = entry.signature ? `${entry.selector} (${entry.signature})` : entry.selector;
    const base = `${entry.target}.${selectorLabel}`;
    if (entry.desired && entry.actual && entry.desired !== entry.actual) {
        return `${base} (desired=${entry.desired}, actual=${entry.actual})`;
    }
    if (entry.desired && !entry.actual) {
        return `${base} (desired=${entry.desired}, actual=OFF)`;
    }
    if (!entry.desired && entry.actual) {
        return `${base} (actual=${entry.actual})`;
    }
    return base;
}
function formatModule(entry) {
    const selectorLabel = entry.signature ? `${entry.selector} (${entry.signature})` : entry.selector;
    return `${entry.target}.${selectorLabel}`;
}
async function main() {
    const args = process.argv.slice(2);
    if (args.includes('--help') || args.includes('-h')) {
        console.log(`Usage: RPC_MAINNET=... RPC_HYPEREVM=... node list-sync/dist/cli.js

Commands (npm scripts):
  npm run verify   Validate YAML against the historical snapshot
  npm run diff     Compare desired YAML state with on-chain guard/module state

Environment:
  RPC_MAINNET      Ethereum JSON-RPC endpoint
  RPC_HYPEREVM     HyperEVM JSON-RPC endpoint`);
        return;
    }
    const results = await diffChains();
    let hasDiff = false;
    for (const result of results) {
        console.log(`Chain ${result.chain.slug} (chainId ${result.chain.chainId})`);
        if (result.guardMissing.length === 0 &&
            result.guardMismatched.length === 0 &&
            result.guardExtra.length === 0 &&
            result.moduleMissing.length === 0 &&
            result.moduleExtra.length === 0) {
            console.log('  ✓ No differences');
            continue;
        }
        hasDiff = true;
        if (result.guardMissing.length > 0) {
            console.log('  Guard missing:');
            for (const entry of result.guardMissing) {
                console.log(`    - ${formatGuard(entry)}`);
            }
        }
        if (result.guardMismatched.length > 0) {
            console.log('  Guard mismatched:');
            for (const entry of result.guardMismatched) {
                console.log(`    - ${formatGuard(entry)}`);
            }
        }
        if (result.guardExtra.length > 0) {
            console.log('  Guard extra:');
            for (const entry of result.guardExtra) {
                console.log(`    - ${formatGuard(entry)}`);
            }
        }
        if (result.moduleMissing.length > 0) {
            console.log('  Module missing:');
            for (const entry of result.moduleMissing) {
                console.log(`    - ${formatModule(entry)}`);
            }
        }
        if (result.moduleExtra.length > 0) {
            console.log('  Module extra:');
            for (const entry of result.moduleExtra) {
                console.log(`    - ${formatModule(entry)}`);
            }
        }
    }
    if (hasDiff) {
        process.exitCode = 1;
    }
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
