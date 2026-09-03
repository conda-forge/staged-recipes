# mq-bridge — how this recipe is built

Both outputs — `mq-bridge-app` and `mq-bridge-py` — ship upstream's **complete**
endpoint set.
Nothing is stripped for build-toolchain reasons.

What differs from `cargo install mq-bridge-app` or the PyPI wheel is *where the
two C libraries come from*: this recipe links conda-forge's `librdkafka` and
`libsqlite` instead of compiling a private copy of each into the binary.
Upstream calls that variant `full-dynamic`, and drives it with
`pixi run build-dynamic`; this recipe is that task, expressed as a conda build.

## Why dynamic linking

conda-forge builds from source against pinned system libraries.
A crate that vendors a C library and compiles its own copy steps outside that:
the result links against something no `run_exports` tracks, so when the
underlying library gets a CVE fix, the package does not get it — the vendored
copy is invisible to conda-forge's rebuild machinery.
conda-forge already ships `librdkafka` and `libsqlite`, so the right answer is to
link those.

The same reasoning applies to `protoc`.
The `grpc` endpoint needs a protobuf compiler at build time, and upstream's
default is `protoc-bin-vendored`, a crate that carries a prebuilt executable.
conda-forge requires that anything executed during a build be a conda package,
so this recipe takes `protoc` from `libprotobuf` instead.

## The three build variants

Upstream's engine separates *which endpoints compile* from *how their C
libraries are obtained*.
The endpoint features (`kafka`, `sqlx`, …) are identical across all three
variants; only the linkage differs.

| Feature set | librdkafka / SQLite | IBM MQ client | pixi task |
| --- | --- | --- | --- |
| `full` | compiled from vendored C sources | `dlopen` at first connect | `build-static` |
| `full-static-ibm-mq` | compiled from vendored C sources | bound at link time (SDK needed to build) | `build-static-ibm-mq` |
| **`full-dynamic`** | **linked from the environment via pkg-config** | `dlopen` at first connect | `build-dynamic` |

`link-static` and `link-dynamic` are mutually exclusive — `sqlx`'s
`sqlite-bundled` and `sqlite-unbundled` hand `libsqlite3-sys` two conflicting
build strategies, and cargo features are additive, so the engine rejects the
combination with a `compile_error!`.

## What the recipe overrides

The linkage split is upstream work in progress, so the recipe carries the
manifests that implement it as whole-file replacements under `source:`.
They are ordinary source files, not patches, and each is upstream's own file
with a narrow change.

| Override | Change |
| --- | --- |
| `Cargo.toml` | Adds `link-static` / `link-dynamic` / `full-dynamic`; drops the `protoc-bin-vendored` build-dependency. |
| `build.rs` | Reads `$PROTOC` from the environment instead of overwriting it; gates the `/opt/mqm` rpath on `ibm-mq-static` rather than on the dlopen `ibm-mq` feature, which never consults it. |
| `src/lib.rs` | The `compile_error!` guards for the linkage features. |
| `docs/IBM_MQ.md` | The document those comments reference. |
| `apps/…/crates/core/Cargo.toml` | A `full-dynamic` passthrough. |
| `apps/…/crates/cli/Cargo.toml` | A `full-dynamic` passthrough. |
| `python/mq-bridge-py/pyproject.toml` | maturin's feature list, pointed at `mq-bridge/full-dynamic`. |

The two app passthroughs exist because of a cargo rule rather than anything
about the code.
`apps/mq-bridge-app` is a separate workspace, and the engine reaches the CLI
through two hops: `crates/cli` depends on `crates/core`, which depends on
`mq-bridge`.
Cargo's `--features dep/feature` syntax only reaches a *direct* dependency, so
from `crates/cli` there is no command line at all that turns on
`mq-bridge/link-dynamic`.
`mq-bridge-py` needs no such passthrough — it depends on `mq-bridge` directly.

## Why both builds run `cargo fetch` first

`--locked` matters here more than it usually does.
`cargo install` **ignores** the committed `Cargo.lock` unless `--locked` is
passed, and re-resolves every dependency to the newest semver-compatible
release.
An earlier revision of this recipe dropped the flag and drew in a fresh
`tinyvec` whose new `with_initial_len` calls `vec!` without importing the macro
and so does not compile under `no_std` — a crate nothing here depends on
directly, breaking a build that had been green the day before.

The committed lock cannot be used verbatim either.
`link-dynamic` selects sqlx's `sqlite-unbundled`, which turns on
`libsqlite3-sys`'s `buildtime_bindgen` and so adds bindgen, `clang-sys` and
their dependencies to the graph — packages upstream's lock never had reason to
record.

`cargo fetch` resolves the difference.
Unlike `cargo install` it is conservative: it keeps every version the lock
already pins and adds only the entries the new features require.
The build then runs under `--locked` against that reconciled lock.

## What is included

Every endpoint upstream ships:

`kafka`, `amqp`, `nats`, `mqtt`, `pulsar` (app only), `mongodb`, `sqlx`
(SQLite/Postgres/MySQL), `postgres_cdc`, `grpc`, `http`, `websocket`,
`clickhouse`, `zeromq` (both the pure-Rust zmq.rs backend and the omq.rs one),
`redis_streams`, `aws` (SQS/SNS), `object_store`/`s3`, `ibmmq`, plus the
always-compiled `memory`, `file`, `dir_spool`, `static`, `ref`, `fanout`,
`stream_buffer`, `switch`, `response`, `reader` and `request` endpoints.

The full `middleware` bundle is enabled in both outputs: metrics, dedup,
compression, encryption and the `filter` expression middleware (which also
supplies the `switch` endpoint's `when` cases).
Retry and dead-letter-queue middleware are not feature-gated upstream and are
present regardless.

TLS uses the `rustls-aws-lc` crypto provider, as upstream's `full` set
specifies.

## IBM MQ

This is the one endpoint that needs something conda-forge cannot supply.

The endpoint **is** compiled in, on upstream's `ibm-mq` (dlopen) path: the build
needs no IBM SDK, and the client library is loaded lazily, on the first connect
of a route that actually opens an IBM MQ endpoint.
Nothing proprietary is vendored, built or shipped here.

To use it, install IBM's redistributable MQ client (9.3.0.0 or later) yourself
and point `MQ_INSTALLATION_PATH` at it — see `docs/IBM_MQ.md` in the source
tree.
Without it, every other endpoint works normally and an `ibm_mq:` route fails
with a non-retryable error naming each path that was tried.

Upstream's `ibm-mq-static` variant, which binds `libmqm_r` at link time and
requires the SDK to build, is deliberately **not** used: it would make the
binary refuse to start on any machine without the IBM client installed.

## Getting a different build

- **Native plugins.** The `plugin` feature is enabled in both outputs, so an
  endpoint built as a separate `mq-bridge` plugin crate can be loaded at
  runtime — `plugins:` in the app's config, or
  `mq_bridge.load_endpoint_plugin` from Python. No rebuild needed.
- **The upstream PyPI wheel.** `pip install mq-bridge-py` gets the `full`
  (statically linked) wheel. Mixing it into a conda environment is the usual
  pip-in-conda tradeoff.
- **Build from source.** `cargo install mq-bridge-app`, or `maturin build`
  against the unmodified `pyproject.toml`.
