# Crystra Evidence

English | [中文](README.zh-CN.md)

evidence-system is the Evidence System of Crystra — an optional, separately deployable, loopback-only data service. It accepts supported OTLP facts from Execution, persists truthful causal and factual projections, and exposes committed state through a versioned read-only query API without controlling execution. Execution continues when Evidence or telemetry is unavailable.

Three modules separate the concerns:

- **Observation Admission** decides what may become accepted, resolves stable record identity, detects duplicate/conflict, and coordinates the transaction.
- **Factual Projection** derives owner-scoped causal and factual state with explicit final/lower-bound/unavailable/not-applicable semantics.
- **Query & API** exposes committed state through the sole external read boundary used by BI and Evolution.

The first release runs as one local Evidence API service and one internal PostgreSQL database. It does not host a UI, proxy a presentation tier, or expose PostgreSQL to consumers.

## Developer preview

This repository is part of Crystra's architecture-first developer preview for trusted local use by individuals and small teams. Admission, projection, query, automatic retention, and the local deployment are implemented and testable. **THERE WILL BE COMPATIBILITY-BREAKING CHANGES.**

## Development

Python 3.13 and 3.14 are supported; local development defaults to the latest available 3.14 patch. [uv](https://docs.astral.sh/uv/) owns dependency locking and builds.

```sh
make sync         # exact dependency environment from uv.lock
make format       # rewrite Python formatting
make lint         # format check, Ruff lint, and strict mypy
make unit         # small tests, no external services
make integration  # ephemeral PostgreSQL 18 migration and integration test
make deployment   # build and smoke-test the loopback Docker Compose deployment
make build        # wheel and sdist in dist/
make check        # non-container quality/build gate
```

The supported Compose deployment publishes the API only on `127.0.0.1:4318`; PostgreSQL has no host-published port. Runtime startup never applies migrations implicitly.

Local startup, separated database roles, file-backed secrets, read-only backup, non-overwriting restore, and the exact negative network checks are documented in [Evidence local operations](docs/operations.md).

## Get the source

This repository is normally consumed as a submodule of [crystra](https://github.com/firestige/crystra):

```sh
git clone --recurse-submodules https://github.com/firestige/crystra.git
```

To clone it standalone:

```sh
git clone https://github.com/firestige/crystra-evidence.git
```

## Documentation

- [Evidence System design](https://github.com/firestige/crystra/blob/main/docs/systems/evidence/evidence-system.md)
- [Evidence implementation baseline](https://github.com/firestige/crystra/blob/main/docs/systems/evidence/implementation-baseline.md)
- [Evidence local operations and retention](docs/operations.md)
- [Conceptual architecture](https://github.com/firestige/crystra/blob/main/docs/agent-architecture.md)
- [Observation Catalog](https://github.com/firestige/crystra/blob/main/docs/contracts/observation/observation-catalog.md)
- [OTel Observation Profile](https://github.com/firestige/crystra/blob/main/docs/contracts/observation/otel-observation-profile.md)
- [Execution–Evidence interaction contract](https://github.com/firestige/crystra/blob/main/docs/contracts/execution-evidence/interaction-contract.md)

## License

[Apache-2.0](LICENSE)

### Local recorded-time query candidate (2026-09-28)

`GET /v1/evidence/traces` also accepts a complete `recorded_from` / `recorded_to`
UTC interval, optionally intersected with one exact Delivery or Trace identity.
The existing Trace page format, cursor and snapshot behavior are retained. The
bounds select `recorded_at` (Evidence acceptance/storage time), inclusively;
native Span start/end times do not select records. Intervals are limited to
366 days, pages to 200 records, and range summaries to 500 Trace identities.
Exceeding the latter returns `QUERY_BOUND_EXCEEDED`; results are never silently
truncated. `/facts` already supports these recorded-time bounds.

This is a local query implementation extension, not a new Observation format
or a published Contracts revision. Exact identity queries remain supported.

## Local Delivery directory query candidate (2026-09-28)

`GET /v1/evidence/deliveries` requires the existing recorded-time interval
`recorded_from` / `recorded_to`. Optional exact filters: `delivery_id`, `task_id`,
`workflow_id`, `workflow_version`; `task_name` is a literal case-insensitive contains
filter. `limit` / `cursor` use the existing repeatable snapshot mechanism.
The response contains `contract: {name: "evidence.delivery-directory", revision: "1.0.0"}`,
`snapshot`, `total`, `items`, `next_cursor`. Each item has `delivery_id`, nullable
`trace_id`, `task_id`, `task_name`, `workflow_id`, `workflow_version`, `started_at`,
and the matched `recorded_at`. `total` is counted before pagination under the same
snapshot. Only metadata is returned, including Deliveries represented by Facts without
available span rows. Multiple Trace identities for one Delivery are an owner-side error.
Start time is display metadata, never the selection clock. Existing Observation and
Contracts schemas are unchanged; this endpoint is a local integration candidate.
