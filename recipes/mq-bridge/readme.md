# mq-bridge — what this recipe leaves out

Upstream builds `mq-bridge` with its `full` feature set.
This recipe does not.
Both outputs — `mq-bridge-app` and `mq-bridge-py` — are built from upstream's
`portable` set instead, which drops every feature that needs a native toolchain
conda-forge cannot reasonably provide.
`mq-bridge-py` matches that set exactly; `mq-bridge-app` deviates in two small
ways, both explained below.

**Yes, Kafka is stripped out.**
It is the largest of the exclusions and the one most likely to surprise someone
who installed this expecting parity with the PyPI wheel or `cargo install`.

## Why anything is stripped at all

Four things drive every exclusion below.
None of them are about the features being unwanted.

**1. conda-forge builds from source against pinned system libraries.**
A conda-forge build runs in a controlled toolchain — a pinned compiler, a pinned
sysroot, and conda-forge's own builds of zlib, OpenSSL, zstd and the rest.
A crate that vendors a C library and compiles its own private copy steps
outside all of that.
The result links against a copy that no `run_exports` tracks, so when the
underlying library gets a CVE fix, this package does not get it — the vendored
copy is invisible to conda-forge's rebuild machinery.
conda-forge already ships `librdkafka` and `libsqlite` as packages; the right
answer is to link those, not to bundle a second copy inside a Rust binary.

**2. Build tools have to come from conda packages.**
conda-forge requires that anything executed during a build be a conda package
built by conda-forge, so its provenance is auditable and it matches the
platform.
A crate that carries a prebuilt executable in its source violates that, and it
also breaks the platform matrix: those vendored binaries exist for a handful of
popular targets and simply do not exist for the rest.

**3. Every dependency must be redistributable and testable in CI.**
conda-forge cannot ship a proprietary client library, and it cannot verify an
endpoint whose runtime dependency is not installable in the CI container.
An endpoint that compiles but can never work for anyone installing from
conda-forge is worse than an absent one — it fails at runtime, in production,
instead of being visibly unavailable up front.

**4. The build has to finish.**
The `full` set compiles aws-lc-sys (BoringSSL), librdkafka, SQLite, protobuf
codegen and the entire tokio/AWS/Mongo graph.
Upstream's own manifest notes that the gRPC feature "can significantly increase
build times".
Two outputs share one CI job here, and CI has a wall-clock limit.

A fifth point is worth stating because it lowers the risk of the whole
approach: **`portable` is upstream's cut, not this recipe's.**
It is the feature set upstream ships for musl/Alpine and Windows arm64 wheels,
for exactly these reasons.
Following it means the excluded surface is a configuration upstream builds and
tests, rather than a novel combination invented here.

## Excluded from both outputs

| Feature | Endpoint / capability lost | Why it was dropped |
| --- | --- | --- |
| `kafka` | `kafka:` endpoint | `rdkafka-sys` builds librdkafka from bundled C sources, with SASL, SSL and zstd. See (1). |
| `sqlx` | `sqlx:` endpoint (SQL sources and sinks) | `libsqlite3-sys` bundles and compiles C SQLite. See (1). |
| `postgres-cdc` | `postgres_cdc:` endpoint (logical-replication change data capture) | Collateral damage. Its wire protocol is pure Rust, but upstream wires it to `sqlx` for the replication-slot control plane, so it inherits SQLite. |
| `grpc` | `grpc:` endpoint | `protoc-bin-vendored` carries a prebuilt `protoc`, and the build script sets `PROTOC` from it unconditionally. See (2). |
| `ibm-mq`, `ibm-mq-static` | `ibmmq:` endpoint | IBM's MQ C client is proprietary and not redistributable. See (3). |
| `zeromq-omq` | The alternative omq.rs ZeroMQ backend | Redundant. The pure-Rust `zeromq` (zmq.rs) backend **is** compiled in, so `zeromq:` endpoints still work; only the `backend: try_omq` fallback path is gone. Compiling a second implementation costs build time for no user-visible gain. |

Two of these are worth being precise about, because "cannot" would overstate the
case:

- **Kafka and SQLx are deferred, not impossible.**
  `rdkafka` has a `dynamic-linking` feature and `libsqlite3-sys` honours
  `SQLITE3_LIB_DIR`, so both could be pointed at conda-forge's `librdkafka` and
  `libsqlite`. That means feature flags, environment wiring, and verification on
  every platform in the matrix — real work, and more than an initial recipe
  submission should carry. If Kafka support is what you actually need, this is
  the tractable follow-up.
- **gRPC needs a patch, not a package.**
  conda-forge ships `protoc` in `libprotobuf`. The blocker is that
  `build.rs` calls `protoc_bin_vendored::protoc_bin_path()` and overwrites
  `PROTOC` with it, so an available system `protoc` is ignored. Teaching it to
  respect a pre-set `PROTOC` is a small upstream change.

IBM MQ is the one genuine "cannot".
The `dlopen` variant would build without the SDK, but the redistributable client
it loads at runtime cannot come from conda-forge, so the endpoint would exist
and never work.

## Excluded from `mq-bridge-py` only

Upstream's `basic` feature set — which is what the reduced wheel and this output
are built from — takes only `metrics` and `dedup` out of the `middleware`
bundle. That leaves three things out:

- **`compression`** — the compression middleware, and batch compression
  (`compression: gzip|lz4|zstd`) on the `file` and `object_store` endpoints.
- **`encryption`** — the AEAD payload-encryption middleware, and at-rest
  encryption on the `file` and `object_store` endpoints.
- **`filter`** — the expression-predicate middleware, and the `when` cases on
  the `switch` endpoint. The `switch` endpoint itself is still present; only its
  conditional routing is unavailable.

The reasons are upstream's, and they differ between the three.
`compression` and `encryption` are dropped because upstream judges the
middleware bundle unnecessary in a production wheel, not because of any build
problem.
`filter` is different: it pulls `zen-expression`, which pulls `psm`, whose build
script assembles per-target stack-switching assembly — so upstream keeps it out
of the set that has to build on every target it publishes wheels for.

`mimalloc` is also not enabled, matching upstream's `basic` set. This is an
allocator choice with no effect on the API.

`mq-bridge-app` **does** enable the full `middleware` bundle, so all three are
available there.
That is the one place this recipe is deliberately less conservative than
`portable`: it accepts the `psm` assembly build, on the judgement that psm
carries hand-written support for the architectures this recipe targets, and that
the `filter` middleware and `switch` conditional routing are close to the point
of a zero-code ETL tool.
Upstream's concern was musl and Windows arm64, neither of which is in this
matrix.
If a platform in the matrix fails to build psm, the fallback is to drop
`middleware` from the app's feature list — which costs metrics, dedup,
compression and encryption along with it, since the CLI crate exposes no
finer-grained passthrough.

## Excluded from `mq-bridge-app` only

Two features are missing for a packaging reason rather than a deliberate one:

- **`clickhouse`** — the `clickhouse:` endpoint.
- **`websocket`** — the `websocket:` endpoint.

Nothing about these two is hard to build — both are already enabled in
`mq-bridge-py`, from the same source tree, in the same recipe.
They are missing because of how the app's manifests are layered.

`apps/mq-bridge-app` is a separate cargo workspace, and the engine reaches the
CLI through two hops: `crates/cli` depends on `crates/core`, which depends on
`mq-bridge`.
Cargo's `--features dep/feature` syntax only reaches a *direct* dependency of
the package being built, so from `crates/cli` the deepest reachable point is
`mq_bridge_app/<feature>` — a feature that `crates/core` has explicitly
re-exported.
`crates/core` re-exports `object-store`, which is why that one is enabled here.
It does not re-export `clickhouse` or `websocket`, and `crates/cli` does not
either, so there is no command line that turns them on.

The fix is a two-line upstream change adding the passthroughs to both manifests,
which is worth sending upstream rather than carrying as a recipe patch.

## What is included

Everything in `portable`, plus the always-compiled endpoints:

`memory`, `file`, `static`, `ref`, `fanout`, `stream_buffer`, `switch`,
`response`, `reader`, `request`, `amqp`, `nats`, `mqtt`, `mongodb`, `http`,
`aws` (SQS/SNS), `zeromq`, `redis_streams`, `object_store`/`s3`, `sled` —
and additionally `clickhouse` and `websocket` in `mq-bridge-py`.

The retry and dead-letter-queue middleware are not feature-gated upstream, so
they are present in both outputs regardless of the above.

TLS uses the `rustls-aws-lc` crypto provider in both outputs, as upstream's
`portable` set specifies.

## What happens if you configure an excluded endpoint

The configuration model is not feature-gated, so a route naming an excluded
endpoint parses successfully. It fails when the route is built — at startup for
a config-driven run — with:

```
[route:<name>] Unsupported consumer endpoint type 'Kafka(...)'
```

or the corresponding `Unsupported publisher endpoint type` for an output.
The failure is loud and immediate; it is not a silent no-op.

## Getting the excluded features anyway

Three options, in rough order of effort:

1. **Native plugins.** The `plugin` feature is enabled in both outputs, so an
   endpoint built as a separate `mq-bridge` plugin crate can be loaded at
   runtime — `plugins:` in the app's config, or
   `mq_bridge.load_endpoint_plugin` from Python. This is the intended extension
   path and needs no rebuild.
2. **The upstream PyPI wheel.** `pip install mq-bridge-py` gets the `full` wheel
   on glibc Linux, macOS and Windows x64, which includes Kafka. Mixing it into a
   conda environment is the usual pip-in-conda tradeoff.
3. **Build from source.** `cargo install mq-bridge-app` or
   `maturin build` against the unmodified `pyproject.toml`, with librdkafka,
   protoc and the IBM SDK provided yourself.
