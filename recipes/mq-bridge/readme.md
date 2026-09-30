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

The linkage split and build-system fixes are included in upstream v0.4.15.
`patches/` carries the one recipe-local change that is still needed for the
tarball.

| Patch | Change |
| --- | --- |
| `0006-build-the-wheel-with-full-dynamic` | maturin's feature list, pointed at `full-dynamic`. Recipe-local — see below. |

`0006` is recipe-local. Upstream names the feature set on maturin's command
line, which a PEP 517 build driven through `pip` never reaches;
`[tool.maturin] features` is where maturin looks when it runs as a build
backend, so that is what has to change here.

Upstream now provides the `full-dynamic` passthroughs in the application and
Python crates, so the conda build can select the same feature set for both
outputs.
