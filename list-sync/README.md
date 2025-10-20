# List Sync

The canonical docs for managing guard/module allowlists now live in the repo root (`README.md`). This folder only contains the YAML archives, TypeScript sources, and compiled CLI output used by that workflow.

- `tags/*.yaml` – declarative batches of guard/module changes
- `chains.yaml` – chain metadata and tag history
- `src/` / `dist/` – TypeScript sources and compiled CLI entry points

For day-to-day flows see the "Allowlist Workflow" section in the root README. The legacy dump lives at `tmp/rumpel_config_dump.jsonl`, and the helper that rebuilds YAML from it is `list-sync/generate-allowlists.mjs`.
