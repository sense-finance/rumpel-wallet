# Legacy snapshot

The list-sync workflow relies on a historical dump of the Solidity guard/module configuration. The dump is stored at `legacy/rumpel_config_dump.jsonl`. Refresh it only when the Solidity source of the guard or module changes and you intentionally want to realign the YAML archive with the new baseline.

To regenerate the archive from a fresh dump:

```bash
node legacy/generate-allowlists.mjs
```

Running the script overwrites the YAML files under `list-sync/tags/`, so make sure you understand the diff before committing changes. No Forge scripts remain in the repo; produce the JSONL snapshot however you prefer, then drop it into this directory before running the helper.
