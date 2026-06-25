#!/bin/bash
set -euxo pipefail

# WCT derives its version from `git describe` when built from a clone. We build
# from a release tarball (no .git), so the wscript falls back to version.txt.
# This bare (digit-leading) version puts WCT's wscript in RELEASE mode
# (is_development() is false) -> it adds "-Werror -Wall -pedantic". That strict
# build is what we WANT for a shipped package; the -Werror sites are handled by
# recipe source patches plus the one targeted downgrade below.
echo "${PKG_VERSION}" > version.txt

# Let waf find the pkg-config'able deps (spdlog, fftw3f, jsoncpp, eigen3, tbb,
# hdf5) inside the conda prefix.
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/share/pkgconfig:${PKG_CONFIG_PATH:-}"

# Demote selected -Werror categories back to warnings; -Werror stays on for
# everything else, and WCT's own genuine warning sites are fixed via recipe
# patches (see source.patches in recipe.yaml), not by widening this list.
#   * -Wdangling-reference: a known GCC-13+ FALSE POSITIVE on boost::multi_array.
#   * -Wdeprecated-literal-operator: a real C++23 deprecation, but it fires only
#     inside the VENDORED util/.../custard/nlohmann/json.hpp (a `""_json` literal
#     with a space). It surfaces only in the ROOT submodule, because conda-forge
#     ROOT (>=6.40) is built with root_cxx_standard=23, so root-config forces
#     `-std=c++23` on the ROOT translation units. Demote rather than patch the
#     bundled third-party header.
# Add each flag ONLY if the active compiler recognizes it: the CUDA build pins an
# older, nvcc-compatible gcc that lacks newer -W names, and the strict
# `-Wno-error=NAME` form ERRORS on an unknown NAME (unlike plain `-Wno-NAME`),
# which would otherwise break every configure test compile.
CXX_PROBE="${CXX:-c++}"
demote=""
for w in dangling-reference deprecated-literal-operator; do
    if printf 'int main(){}\n' | "${CXX_PROBE}" -Wno-error="${w}" -fsyntax-only -x c++ - 2>/dev/null; then
        demote="${demote} -Wno-error=${w}"
    fi
done
export CXXFLAGS="${demote} ${CXXFLAGS:-}"

# waf's find_program('python') otherwise resolves to the HOST-env python, which
# is a non-executable relocation placeholder during the build (a host dep pulls
# python into $PREFIX). Force waf to the build-env interpreter, which is the one
# actually runnable now. waf honors the PYTHON env var as a find_program override.
export PYTHON="${BUILD_PREFIX}/bin/python"

# Optional-feature flags, driven by the variant toggles in variants.yaml.
# rattler-build exports each variant key into the build environment, so
# ${wct_with_root}/${wct_with_libtorch} are "true"/"false" here. We pass the
# conda $PREFIX as the package location (waf's generic --with-NAME=<dir> form:
# `=true` would use pkg-config, which libtorch has no .pc for). Defaults match
# variants.yaml ("true") in case the key is somehow unset.
WITH_FLAGS=()
if [ "${wct_with_root:-true}" = "true" ]; then
    WITH_FLAGS+=( --with-root="${PREFIX}" )
fi
if [ "${wct_with_libtorch:-true}" = "true" ]; then
    # libtorch's headers are split: the low-level headers are in $PREFIX/include
    # but the high-level C++ API (torch/torch.h) lives under
    # include/torch/csrc/api/include. WCT's `generic` waf tool splits
    # --with-NAME-include on commas, so pass BOTH dirs (matches the wire-cell
    # spack recipe). libtorch has no .pc file, so the include/lib dirs are read
    # directly rather than via pkg-config.
    WITH_FLAGS+=(
        --with-libtorch="${PREFIX}"
        --with-libtorch-include="${PREFIX}/include,${PREFIX}/include/torch/csrc/api/include"
        --with-libtorch-lib="${PREFIX}/lib"
    )
fi
if [ "${wct_with_cuda:-false}" = "true" ]; then
    # WCT's cuda.py wants cuda.h + libcuda/libcudart + nvcc. conda's CUDA headers
    # and stub libs live under $PREFIX/targets/<arch>/{include,lib} (with nvcc in
    # $PREFIX/bin), so point the include/lib dirs there explicitly rather than at
    # $PREFIX/include. (cuda.h = Driver API header from cuda-driver-dev.)
    cuda_arch_dir="${PREFIX}/targets/x86_64-linux"
    WITH_FLAGS+=(
        --with-cuda="${PREFIX}"
        --with-cuda-include="${cuda_arch_dir}/include,${PREFIX}/include"
        --with-cuda-lib="${cuda_arch_dir}/lib,${PREFIX}/lib"
    )
fi

./wcb configure \
    --prefix="${PREFIX}" \
    --boost-includes="${PREFIX}/include" \
    --boost-libs="${PREFIX}/lib" \
    --with-jsonnet="${PREFIX}" \
    "${WITH_FLAGS[@]}"

./wcb -j"${CPU_COUNT}"
./wcb install
