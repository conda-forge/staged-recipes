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
  flags, so keep the three source patches and the `-Wno-error=dangling-reference`
  CXXFLAGS demotion from the recipe.
