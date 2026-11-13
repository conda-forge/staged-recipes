# TokenSpeed

This recipe packages six Python distributions in the TokenSpeed monorepo:

| Output | Version | Implementation |
| --- | --- | --- |
| tokenspeed | 0.1.1 | Python inference runtime and `tokenspeed` / `ts` commands |
| tokenspeed-kernel | 0.1.4 | Python kernels and compiled CUDA shared libraries |
| tokenspeed-kernel-amd | 0.1.4 | AMD kernel sources |
| tokenspeed-kernel-npu | 0.1.0 | Ascend kernel sources |
| tokenspeed-mla | 0.2.16 | JIT-compiled MLA kernel sources |
| tokenspeed-scheduler | 0.1.25 | C++ scheduler and nanobind extension |

The source uses the public `v0.1.1` release archive with a verified SHA-256
checksum. Each output retains its version from that release. Internal dependencies are pinned to the matching output build.
This release does not contain a separate engine distribution or require a
`tokenspeed-engine` dependency.
All outputs target Linux; the CUDA kernel build targets Blackwell SM100a and
SM103a using CUDA 13.0. All distributions require Python 3.10 or later.

## Build prerequisites

This is a recipe draft pending dependency feedstocks. The following upstream
forks were absent from conda-forge when checked against the Anaconda package API
on November 3, 2026:

- tokenspeed-spdlog
- tokenspeed-triton and tokenspeed-proton
- tokenspeed-mooncake
- tokenspeed-smg, tokenspeed-smg-grpc-proto, tokenspeed-smg-grpc-servicer
- tokenspeed-deepep, tokenspeed-deepgemm, tokenspeed-flashmla, tokenspeed-deepselect
- tokenspeed-fast-hadamard-transform
- tokenspeed-fa3, tokenspeed-fa4, tokenspeed-quack, tokenspeed-trtllm-kernel
- tokenspeed-flashkda and tokenspeed-cutedsl-kda

`triton-ascend`, `nvidia-cudnn-frontend`, and
`nvidia-cutlass-dsl-libs-cu13` were also absent. Existing packages must additionally
provide the upstream version constraints recorded in `recipe.yaml`, including
PyTorch 2.14.0 and CuTe DSL 4.8.0. These dependencies need separate recipes or
compatible conda-forge builds before this recipe can build and pass its tests.
The fork names are intentional: upstream imports names such as
`tokenspeed_triton`, so substituting stock Triton does not provide the same API.

The kernel patch disables upstream's nested pip dependency installation and
uses the conda include directory and linker flags. Dependency installation is
handled by the recipe.

## Validation

Run conda-forge lint with:

```sh
conda-smithy recipe-lint --conda-forge recipes/tokenspeed
```

To render with a concrete Python variant, create a variant file containing
`python: ["3.12"]`, `c_stdlib: ["sysroot"]`, and
`c_stdlib_version: ["2.28"]`, then run:

```sh
rattler-build build -r recipes/tokenspeed -m /path/to/variants.yaml --render-only
```

Each output declares import and pip metadata checks. The CUDA output checks for
a compiled kernel library,
and the runtime checks both CLI entry points. These smoke tests do not exercise
GPU inference and a full build has not been completed while dependencies are
missing.
