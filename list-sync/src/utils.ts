import { keccak256, toUtf8Bytes } from 'ethers';

export function normalizeAddress(value: string, context: string): string {
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

export function normalizeSelector(value: string, context: string): { selector: string; signature?: string } {
  if (typeof value !== 'string') {
    throw new Error(`Expected selector string for ${context}`);
  }

  const trimmed = value.trim();

  if (/^0x[0-9a-fA-F]{8}$/.test(trimmed)) {
    return { selector: trimmed.toLowerCase() };
  }

  if (trimmed.includes('(') && trimmed.endsWith(')')) {
    const hash = keccak256(toUtf8Bytes(trimmed));
    return { selector: hash.slice(0, 10), signature: trimmed };
  }

  throw new Error(`Selector must be 4-byte hex or signature for ${context}: ${value}`);
}
