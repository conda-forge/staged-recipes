# mq-bridge — how this build differs from upstream

Both outputs ship upstream's **complete** endpoint set. Nothing is stripped.

The one difference is where the C libraries come from. Upstream separates
*which* endpoints compile from *how* their native libraries are obtained:
`full` compiles vendored copies of librdkafka and SQLite into the binary, while
`full-dynamic` links the ones already in the environment. This recipe builds
`full-dynamic` — upstream's own `pixi run build-dynamic`, expressed as a conda
build.

`protoc` follows the same rule. The `grpc` endpoint needs a protobuf compiler at
build time, and upstream's default is `protoc-bin-vendored`, a crate carrying a
prebuilt executable; here it comes from `libprotobuf`.

Both changes are conda-forge requirements rather than preferences. A vendored C
library is invisible to `run_exports`, so a CVE fix in librdkafka would never
reach a package that compiled its own copy; and anything executed during a build
has to be a conda package.

## What the recipe overrides

The linkage split is upstream work in progress, so the recipe carries the
manifests that implement it as whole-file replacements under `source:`. Each is
upstream's own file with a narrow change — drop the entry once the change
reaches a release.

| Override | Change |
| --- | --- |
| `Cargo.toml` | Adds `link-static` / `link-dynamic` / `full-dynamic`; drops the `protoc-bin-vendored` build-dependency. |
| `build.rs` | Reads `$PROTOC` from the environment instead of overwriting it; gates the `/opt/mqm` rpath on `ibm-mq-static` rather than on the dlopen `ibm-mq` feature, which never consults it. |
| `src/lib.rs` | `compile_error!` guards for the linkage features, which are mutually exclusive. |
| `apps/…/crates/core/Cargo.toml` | A `full-dynamic` passthrough. |
| `apps/…/crates/cli/Cargo.toml` | A `full-dynamic` passthrough. |
| `python/mq-bridge-py/pyproject.toml` | maturin's feature list, pointed at `mq-bridge/full-dynamic`. |

The two app passthroughs exist because of a cargo rule rather than anything
about the code. `apps/mq-bridge-app` is a separate workspace, and the engine
reaches the CLI through two hops: `crates/cli` depends on `crates/core`, which
depends on `mq-bridge`. Cargo's `--features dep/feature` syntax only reaches a
*direct* dependency, so from `crates/cli` there is no command line at all that
turns on `mq-bridge/link-dynamic`. `mq-bridge-py` needs no passthrough — it
depends on `mq-bridge` directly.
