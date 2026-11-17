#!/bin/bash
set -euxo pipefail
export CUDA_HOME="${PREFIX}"
# CUDA headers live under targets/, rather than the prefix's include directory.
# target_platform is supplied by rattler-build.
# shellcheck disable=SC2154
case "${target_platform}" in
    linux-64) cuda_target=x86_64-linux ;;
    linux-aarch64) cuda_target=aarch64-linux ;;
    *) echo "Unsupported CUDA target: ${target_platform}" >&2; exit 1 ;;
esac
export CPPFLAGS="${CPPFLAGS:-} -I${PREFIX}/targets/${cuda_target}/include"
"${PYTHON}" -m pip install ./python --no-deps --no-build-isolation -vv
