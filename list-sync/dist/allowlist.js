import { readdirSync, readFileSync } from 'fs';
import { join } from 'path';
import { parse } from 'yaml';
const VALID_STATES = ['OFF', 'ON', 'PERMANENTLY_ON'];
function normalizeState(value, context) {
    if (VALID_STATES.includes(value)) {
        return value;
    }
    throw new Error(`Invalid allowlist state "${value}" (${context})`);
}
function normalizeAddress(value, context) {
    if (typeof value !== 'string') {
        throw new Error(`Expected address string for ${context}`);
    }
    if (!value.startsWith('0x')) {
        throw new Error(`Address missing 0x prefix for ${context}: ${value}`);
    }
    if (value.length !== 42) {
        throw new Error(`Address must be 42 chars for ${context}: ${value}`);
    }
    return value.toLowerCase();
}
function normalizeSelector(value, context) {
    if (typeof value !== 'string') {
        throw new Error(`Expected selector string for ${context}`);
    }
    if (!/^0x[0-9a-fA-F]{8}$/.test(value)) {
        throw new Error(`Selector must be 4-byte hex for ${context}: ${value}`);
    }
    return value.toLowerCase();
}
export function loadAllowlistFile(path) {
    const raw = parse(readFileSync(path, 'utf8'));
    if (!raw || typeof raw !== 'object') {
        throw new Error(`Allowlist file ${path} did not parse to an object`);
    }
    if (!raw.slug) {
        throw new Error(`Allowlist file ${path} missing slug`);
    }
    const guardCalls = [];
    const guardTokens = [];
    const moduleBlocks = [];
    const moduleTokens = [];
    if (raw.guard?.allow) {
        for (const entry of raw.guard.allow) {
            const target = normalizeAddress(entry.target, `${raw.slug} guard.allow target`);
            for (const selector of entry.selectors ?? []) {
                guardCalls.push({
                    target,
                    selector: normalizeSelector(selector.selector, `${raw.slug} guard.allow selector`),
                    state: normalizeState(selector.state, `${raw.slug} guard.allow state`),
                });
            }
        }
    }
    if (raw.guard?.tokens) {
        for (const entry of raw.guard.tokens) {
            const token = normalizeAddress(entry.token, `${raw.slug} guard.tokens token`);
            guardTokens.push({
                token,
                transfer: normalizeState(entry.transfer, `${raw.slug} guard.tokens transfer`),
                approve: normalizeState(entry.approve, `${raw.slug} guard.tokens approve`),
            });
        }
    }
    if (raw.module?.block) {
        for (const entry of raw.module.block) {
            const target = normalizeAddress(entry.target, `${raw.slug} module.block target`);
            for (const selector of entry.selectors ?? []) {
                moduleBlocks.push({
                    target,
                    selector: normalizeSelector(selector, `${raw.slug} module.block selector`),
                });
            }
        }
    }
    if (raw.module?.tokens) {
        for (const entry of raw.module.tokens) {
            const token = normalizeAddress(entry.token, `${raw.slug} module.tokens token`);
            moduleTokens.push({
                token,
                transfer: Boolean(entry.transfer),
                approve: Boolean(entry.approve),
            });
        }
    }
    return {
        slug: raw.slug,
        guard: { calls: guardCalls, tokens: guardTokens },
        module: { blocks: moduleBlocks, tokens: moduleTokens },
    };
}
export function loadAllAllowlists(dir) {
    const files = readdirSync(dir)
        .filter((file) => file.endsWith('.yaml'))
        .map((file) => join(dir, file))
        .sort();
    return files.map((file) => loadAllowlistFile(file));
}
export function flattenAllowlist(data) {
    const records = [];
    for (const call of data.guard.calls) {
        records.push({
            slug: data.slug,
            kind: 'guard.call',
            target: call.target,
            selector: call.selector,
            state: call.state,
        });
    }
    for (const token of data.guard.tokens) {
        records.push({
            slug: data.slug,
            kind: 'guard.token',
            token: token.token,
            transferState: token.transfer,
            approveState: token.approve,
        });
    }
    for (const block of data.module.blocks) {
        records.push({
            slug: data.slug,
            kind: 'module.call',
            target: block.target,
            selector: block.selector,
        });
    }
    for (const token of data.module.tokens) {
        records.push({
            slug: data.slug,
            kind: 'module.token',
            token: token.token,
            blockTransfer: token.transfer,
            blockApprove: token.approve,
        });
    }
    return records;
}
