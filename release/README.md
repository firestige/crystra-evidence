# Crystra Evidence release adapter

The component publishes wheel/sdist assets and a digest-bound GHCR image. It retains PostgreSQL and the Evidence Query domain API.

```sh
uv run python -m release.cli.release config
make check
make integration
make deployment
```

A push to `release/next` qualifies that component commit and its own publisher tools. `release/request.json` supplies the `crystra-evidence-v<version>-rc.N` tag; `config/development-contract.json` supplies the exact independent Contracts input. The current Evidence Query binding and conformance tests replace the historical publication record requirement. No combination checkout or prior combination pin is needed.

The candidate preserves the local acceptance gates, immutable OCI provenance checks, exact Python assets, resumable byte comparisons, and remote download verification. A repository-scoped App token is minted only after qualification for RC creation. Stable promotion remains a human gate and reuses qualified bytes, with tag `crystra-evidence-v<version>`. No old WSR artifact or data migration is supported.

Crystra candidates are not published yet. Repository coordinates, App configuration and the full product installation are completed in the rename plan before candidate publication.
