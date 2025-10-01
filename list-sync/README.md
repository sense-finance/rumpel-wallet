# List Sync

Declarative tag files for the Rumpel guard and module live here. Each YAML captures a chronological batch of allow/block updates so we can reason about history, generate Safe batches, and diff desired behaviour against what is on-chain.

## Directory layout

- `tags/*.yaml` – one file per tag/slug. Each file records guard call states, token allow entries, and module block entries applied during that tag.
- `chains.yaml` – known chains, guard/module addresses, JSON-RPC env vars, and the ordered list of tags to apply. Tags are evaluated in the listed order; later tags overwrite earlier state for the same `<target>.<selector>` pair.
- `src/` – TypeScript tooling that parses the YAML, flattens it, and performs verification / on-chain diffs.
- `dist/` – Compiled output from `tsc` (do not hand-edit).

## Common tasks

### 1. Add or edit an allowlist tag

1. Create/edit the appropriate file in `tags/`. Slug names should match the historical naming pattern (e.g. `something-useful.yaml`).
2. Populate the `guard.allow` section with any protocol selectors (either 4-byte hex like `0xabcdef01` or full signatures such as `deposit(uint256,address)`) and target addresses being enabled.
3. Populate the `guard.tokens` section for ERC20 transfer/approve states – these translate to `transfer(address,uint256)` / `approve(address,uint256)` selectors.
4. Populate the `module.block` and `module.tokens` sections for module-level blocklist entries as needed.
5. Run `npm run typecheck` (from `list-sync/`) to ensure the schema stays valid.
6. Run `npm run verify` to confirm the YAML still matches the historical Solidity snapshot (`tmp/rumpel_config_dump.jsonl`). Update the snapshot only if you intentionally diverged from the legacy config.

### 2. Update chain composition

1. Edit `chains.yaml` and adjust the `tags` array for the relevant chain. Tags are applied sequentially from top to bottom, so append new tags to the end unless you are intentionally re-ordering history.
2. Rerun `npm run typecheck` to validate the YAML and `npm run diff` to see the new desired vs actual state.

### 3. Run verification / diff tooling

All commands below should be executed from `list-sync/`.

```bash
# Install dependencies once
npm install

# Recompile TypeScript
npm run build

# Ensure YAML matches the historical Solidity dump
npm run verify

# Compare desired YAML against on-chain guard/module state
npm run diff

# Generate Safe batches for a tag (dry run first)
npm run sync -- --tag new-tag --dry-run
npm run sync -- --tag new-tag
```

> Both `npm run diff` and `npm run sync` expect `RPC_MAINNET` / `RPC_HYPEREVM` (and any other chain RPCs) to be available in your environment—drop them in `.env`, `direnv`, or your shell profile once and the commands stay terse.

CLI help is also available via `node dist/cli.js --help`.

### 4. Queue changes on-chain

1. Use the sync helper to emit Safe batches straight from the YAML:
   ```bash
   npm run sync -- --tag cap-money-expansion-sep-15
   ```
   This writes `safe-batches/cap-money-expansion-sep-15-<chain>.json` files containing the guard/module updates for each chain that lists the tag.
2. Upload the JSON into the Safe Transaction Builder, review, and execute.
3. After execution, re-run `npm run diff` to confirm the on-chain state matches the desired YAML.

### 5. Regenerate the historical snapshot (if needed)

The file `tmp/rumpel_config_dump.jsonl` is produced by the legacy Forge helper:

```bash
forge script script/DumpRumpelConfig.s.sol --tc DumpRumpelConfig --sig "run()" \
  | sed -n 's/^  //p' > tmp/rumpel_config_dump.jsonl
```

You only need to refresh it if `script/RumpelConfig.sol` changes and you want the YAML archive to reflect the new baseline before migrating fully.

## Tag ordering = history

Tags in `chains.yaml` are applied sequentially. Moving a tag earlier in the list will retroactively change the final allowlist for every chain that references it. Treat the list as append-only:

- When introducing a new tag, append it to the end of each chain’s list.
- If you need to “undo” something, create a new tag that explicitly reverts the selector/token state rather than reordering history.

> Tip: you can add a quick CI check that ensures git diffs only append to the arrays if you want to enforce this automatically.

## What happens if on-chain state drifts?

Running `npm run diff` highlights any divergence between the YAML and the live guard/module. When you subsequently run `npm run sync -- --tag <slug>` the tool:

- Queries the current on-chain state for every selector in that tag.
- Emits transactions **only** for mismatches, skipping anything that already matches.
- Refuses to downgrade selectors that are permanently allowed (mirroring the Solidity guard logic).

If you execute `sync` for an older tag after other tags have already run, it will try to restore that tag’s desired state. In practice you should rerun `diff` first and, if the difference is intentional, update the YAML (e.g. append a new tag) so history stays consistent.

## One-off generation helpers

`list-sync/generate-allowlists.mjs` and `script/DumpRumpelConfig.s.sol` exist so we can regenerate the YAML archive from the original Solidity if we need to. Day-to-day workflows don’t require them, but keep them around if you anticipate another bulk export.

## Tag precedence

When multiple tags reference the same `<target>.<selector>` pair:

- **Guard**: the last tag in the chain list wins. Later tags can overwrite earlier `ON`/`OFF`/`PERMANENTLY_ON` states.
- **Module**: entries accumulate. Any later tag that re-lists the same block keeps it blocked; removing a block requires a dedicated tag that omits it (which currently implies manual intervention).

Maintain chronological ordering in `chains.yaml` so earlier tags represent history and later tags represent accretive changes.

## Event scan start blocks

The diff engine scans chain logs from the configured `startBlock`. Keep these values at or just before the deployment blocks for guard/module contracts to minimise RPC load while still capturing the full history.
