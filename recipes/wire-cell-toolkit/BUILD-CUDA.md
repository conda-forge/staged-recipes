# Building Wire-Cell Toolkit with CUDA by hand

The conda-forge `wire-cell-toolkit` package does **not** enable CUDA. CUDA is a
build-time feature that would make the default package require a CUDA runtime, so
it is intended to ship later as a *separate* conda-forge variant (CPU default +
`cuda`-enabled variant). Until that variant lands, this note explains how to
produce a CUDA-enabled WCT build yourself.

CUDA is a **build-time** choice: you cannot turn it on for an already-built
`.conda`. You must rebuild from source (either via the recipe with an override,
or by driving `./wcb` directly).

## What WCT needs for CUDA

From `waft/cuda.py` and `waft/libtorch.py` in the WCT source:

- The `cuda` submodule (`libWireCellCuda`) is gated on `HAVE_CUDA`, which WCT
  satisfies by finding **`nvcc`**, the header **`cuda.h`** (CUDA Driver API), and
  the libs **`cuda`** + **`cudart`**.
- Enabling CUDA also changes the **libtorch** link set: `libtorch.py` adds
  `torch_cuda` and `c10_cuda` (and a `-Wl,--no-as-needed,-ltorch_cuda` link
  flag). So a CUDA build needs a **CUDA-enabled libtorch**, not the CPU one.

The relevant `./wcb configure` flags (waf `generic` tool):

```
--with-cuda=<dir>            # or --with-cuda-include / --with-cuda-lib
--with-libtorch=<dir>
--with-libtorch-include=<dir>,<dir>/torch/csrc/api/include
--with-libtorch-lib=<dir>/lib
```

## Option A — rebuild the recipe with a CUDA toggle (recommended)

This reuses the recipe's optional-feature machinery (see `variants.yaml`). Add a
`wct_with_cuda` key and the CUDA host deps, then build against a CUDA channel.

1. Add CUDA deps to `recipe.yaml` `host:` (gated like the other toggles):

   ```yaml
   - if: wct_with_cuda == "true"
     then:
       - cuda-version {{ cuda_version }}   # e.g. 12.6
       - cuda-nvcc                          # nvcc
       - cuda-driver-dev                    # cuda.h + libcuda stub
       - cuda-cudart-dev                    # cudart
       - libtorch =*=cuda*                  # CUDA-enabled libtorch
   ```

   and add a CUDA compiler to `build:`:

   ```yaml
   requirements:
     build:
       - {{ compiler('cuda') }}
   ```

2. Add the configure flag in `build.sh` (next to the libtorch block):

   ```bash
   if [ "${wct_with_cuda:-false}" = "true" ]; then
       WITH_FLAGS+=( --with-cuda="${PREFIX}" )
   fi
   ```

3. Build with CUDA on (override the toggle; the recipe default stays CPU):

   ```bash
   rattler-build build --recipe recipe.yaml \
     --variant-config <(printf 'wct_with_cuda: ["true"]\ncuda_compiler_version: ["12.6"]\n')
   ```

   On a machine without a GPU you can still compile (nvcc needs no GPU), but the
   `wire-cell --help` test runs fine; GPU code paths only need a device at run
   time.

> Verify the exact conda-forge CUDA package names/versions against the current
> `cuda-version` pin before relying on them — the CUDA package split has changed
> across CUDA 11/12 (`cudatoolkit` → the `cuda-*` component packages).

## Option B — drive `./wcb` directly against a CUDA environment

If you just want a local tree built (no `.conda`), make an env with the toolkit
and a CUDA libtorch, then configure WCT against it. Example with pixi/conda:

```bash
# 1. Environment with WCT's core deps + CUDA toolkit + CUDA libtorch.
#    (names per conda-forge CUDA 12.x; adjust the version to your GPU/driver)
conda create -n wct-cuda -c conda-forge \
    cxx-compiler pkg-config python \
    libboost-devel eigen jsoncpp libjsonnet go-jsonnet spdlog fmt fftw \
    tbb-devel hdf5 glpk zlib bzip2 root \
    cuda-version=12.6 cuda-nvcc cuda-driver-dev cuda-cudart-dev \
    "libtorch=*=cuda*"
conda activate wct-cuda

# 2. Configure + build WCT against $CONDA_PREFIX.
cd wire-cell-toolkit
export PKG_CONFIG_PATH="$CONDA_PREFIX/lib/pkgconfig:$CONDA_PREFIX/share/pkgconfig:${PKG_CONFIG_PATH:-}"
export CXXFLAGS="-Wno-error=dangling-reference ${CXXFLAGS:-}"

./wcb configure \
    --prefix="$CONDA_PREFIX" \
    --boost-includes="$CONDA_PREFIX/include" \
    --boost-libs="$CONDA_PREFIX/lib" \
    --with-jsonnet="$CONDA_PREFIX" \
    --with-root="$CONDA_PREFIX" \
    --with-libtorch="$CONDA_PREFIX" \
    --with-libtorch-include="$CONDA_PREFIX/include,$CONDA_PREFIX/include/torch/csrc/api/include" \
    --with-libtorch-lib="$CONDA_PREFIX/lib" \
    --with-cuda="$CONDA_PREFIX"

./wcb -j"$(nproc)"
./wcb install
```

Confirm CUDA was picked up: `./wcb configure` prints the configured submodule
list — look for `cuda` (and `pytorch`) in
`Configured for submodules: ...`, and check
`build/WireCellUtil/BuildConfig.h` for `HAVE_CUDA`.

## Notes / gotchas

- **`cuda.h` vs `cuda_runtime.h`.** WCT looks for `cuda.h` (the Driver API
  header), which comes from `cuda-driver-dev` on conda-forge, *not* the runtime
  header in `cuda-cudart-dev`. Install both.
- **libtorch must match.** A CPU `libtorch` will fail the CUDA link (missing
  `torch_cuda`/`c10_cuda`). Pin the CUDA build: `libtorch=*=cuda*`.
- **Driver vs toolkit.** Compiling needs only the toolkit (`nvcc`, headers,
  stub libs); *running* GPU kernels needs a real NVIDIA driver/`libcuda` on the
  host. The conda `cuda-driver-dev` ships only the link stub.
- **The `-Werror` patches still apply** — the CUDA build uses the same release
  flags, so keep the three source patches and the `-Wno-error=…` CXXFLAGS
  demotions from the recipe.
- **A CUDA build pins gcc DOWN.** conda-forge constrains the host gcc to a version
  `nvcc` supports (older than the CPU build's gcc 15). That older gcc lacks
  `-Wdeprecated-literal-operator`, and the strict `-Wno-error=NAME` form *errors*
  on an unknown NAME (unlike plain `-Wno-NAME`) — which breaks every `./wcb`
  configure test compile (it surfaces misleadingly as "boost/core/span.hpp: not
  found"). `build.sh` handles this by **probing the compiler** and adding each
  `-Wno-error=` flag only if recognized. The same older gcc also doesn't emit the
  C++23 nlohmann-json deprecation, so the demotion simply isn't needed there.

## Future: build BOTH cpu and cuda flavors on conda-forge

The current `wct_with_cuda` toggle is a **local, single-value** switch (one build
at a time). conda-forge can instead build BOTH flavors and ship them side by side
(same as the pytorch / mpi / blas feedstocks). To do that LATER:

1. **Switch the gating axis from `wct_with_cuda` to conda-forge's standard
   `cuda_compiler_version`.** Keep `wct_with_cuda` as a local alias if handy, but
   the conda-forge matrix must key off `cuda_compiler_version` so the `__cuda`
   run-export and build-string machinery engage. Replace the gate conditions:
   - `${{ "libtorch * cuda*" if cuda_compiler_version != "None" else "libtorch * cpu*" }}`
   - `- if: cuda_compiler_version != "None"` for the cuda toolkit host deps and
     `${{ compiler('cuda') }}` in build.
   - In `build.sh`, drive `--with-cuda` off `cuda_compiler_version` (treat
     `"None"`/unset as CPU) instead of `wct_with_cuda`.

2. **Declare the matrix in the FEEDSTOCK, not here.** staged-recipes proves a
   single build; the variant matrix lives in the generated feedstock's
   `recipe/conda_build_config.yaml`:
   ```yaml
   cuda_compiler_version:
     - "None"     # CPU build
     - "12.6"     # CUDA build (pick the conda-forge-pinned CUDA version[s])
   ```
   `conda-smithy rerender` then emits one CI job per value.

3. **Coexistence + selection is automatic** once you key off `cuda_compiler_version`:
   the two builds get different build hashes, the cuda build carries a `__cuda`
   run requirement (only installable where a GPU/driver exists), and
   `cuda-version` pins the stack. No extra metadata needed for them to live in the
   channel together.

4. **Add the CUDA runtime to `run:`** for the cuda variant so the
   `libcudart`/`libcuda` links are "expected" (silences the overlinking warnings
   seen locally and is what the linter wants).

### Caveats before committing to a matrix
- **CI cost doubles** (one extra job per CUDA version) and each CUDA job pulls the
  ~800 MB cuda libtorch + toolkit. This recipe is already heavy (ROOT + libtorch);
  conda-forge CI has time limits, so consider restricting to a single CUDA version
  or splitting CUDA out.
- The matrix **multiplies** with any future axis (e.g. a python axis →
  `python × cuda` jobs).
- Reviewers will scrutinize the CUDA selection/`__cuda` behavior — following the
  standard `cuda_compiler_version` pattern (not a custom toggle) is what they
  expect and what makes coexistence work.
