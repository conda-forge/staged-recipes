# mq-bridge — how this build differs from upstream

Both outputs ship upstream's **complete** endpoint set. Nothing is stripped.

The one difference is where the C libraries come from. Upstream separates
*which* endpoints compile from *how* their native libraries are obtained:
`full` compiles a vendored librdkafka into the binary, while `full-dynamic`
links the one already in the environment. This recipe builds `full-dynamic` —
upstream's own `just build-dynamic`, expressed as a conda build.

SQLite is not part of that split. sqlx's `sqlite-bundled` and
`sqlite-unbundled` hand `libsqlite3-sys` two conflicting build strategies, so
exactly one has to be chosen, and upstream picks the bundled amalgamation in
both variants. There is consequently no `libsqlite` host dependency here.
Generating bindings against a shared libsqlite3 was also the only thing that
made `libclang` a hard requirement; it stays in `build:` as a fallback for
`aws-lc-sys`, which reaches for bindgen on targets it has no prebuilt bindings
for.

`protoc` comes from the environment for the same reason librdkafka does. The
`grpc` endpoint needs a protobuf compiler at build time, and upstream's default
is `protoc-bin-vendored`, a crate carrying a prebuilt executable; `full-dynamic`
drops it, and here the compiler comes from `libprotobuf`.

Both are conda-forge requirements rather than preferences. A vendored C
library is invisible to `run_exports`, so a CVE fix in librdkafka would never
reach a package that compiled its own copy; and anything executed during a build
has to be a conda package.

## What the recipe patches

The linkage split is upstream work in progress, living on
[`feature/dynamic-c-linkage`](https://github.com/marcomq/mq-bridge/tree/feature/dynamic-c-linkage).
`patches/` carries that branch squashed by topic and rebased onto the v0.4.11
tarball — drop each patch as its change reaches a release.

| Patch | Change |
| --- | --- |
| `0001-split-native-linkage-into-its-own-features` | Moves the endpoint list to `full-common`; adds `link-static` / `link-dynamic` / `full-dynamic`, and `vendored-protoc` for the `protoc-bin-vendored` build-dependency `grpc` used to pull in unconditionally. Pins SQLite to `sqlite-bundled`. |
| `0002-relock-sqlx-without-default-features` | `Cargo.lock`, regenerated for the sqlx change above, so `--locked` still holds. |
| `0003-reject-both-linkage-features-at-compile-time` | `compile_error!` guard: the linkage features are mutually exclusive, and cargo features are additive. |
| `0004-take-protoc-from-the-environment` | Reads `$PROTOC` instead of overwriting it with the vendored binary; extends the `/opt/mqm` rpath gate to `ibm-mq-static`, which is the feature that actually links against it. |
| `0005-full-dynamic-passthroughs-for-the-dependent-crates` | `full-dynamic` in `crates/core`, `crates/cli` and `mq-bridge-py`. |
| `0006-build-the-wheel-with-full-dynamic` | maturin's feature list, pointed at `full-dynamic`. Recipe-local — see below. |

`0006` is the only one with no upstream counterpart. Upstream names the feature
set on maturin's command line, which a PEP 517 build driven through `pip` never
reaches; `[tool.maturin] features` is where maturin looks when it runs as a
build backend, so that is what has to change here.

The two app passthroughs exist because of a cargo rule rather than anything
about the code. `apps/mq-bridge-app` is a separate workspace, and the engine
reaches the CLI through two hops: `crates/cli` depends on `crates/core`, which
depends on `mq-bridge`. Cargo's `--features dep/feature` syntax only reaches a
*direct* dependency, so from `crates/cli` there is no command line at all that
turns on `mq-bridge/link-dynamic`. `mq-bridge-py` depends on `mq-bridge`
directly and would not strictly need one; it gets a passthrough anyway, so that
`pyproject.toml` can name a feature instead of re-spelling the whole list.
