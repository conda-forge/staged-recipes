#!/bin/bash
set -ex

# Generate the kernel instantiations with setup.py's "default" split policy
for spec in reference_fna:2 fna:64 fmha:6 \
            hopper_fna:8 hopper_fna_bwd:4 hopper_fmha:5 hopper_fmha_bwd:5 \
            blackwell_fna:28 blackwell_fna_bwd:14 blackwell_fmha:4 blackwell_fmha_bwd:4; do
    "${BUILD_PREFIX}/bin/python" "scripts/autogen_${spec%%:*}.py" \
        --num-splits "${spec##*:}" -o csrc
done

# The kernels and csrc/src wrappers only use the C++ API (ATen/c10), so include
# torch/all.h instead of torch/extension.h, which also pulls in the Python and
# pybind11 headers. natten.cpp keeps torch/extension.h; it is built per Python.
grep -rl 'torch/extension.h' csrc/src csrc/autogen | xargs sed -i 's#torch/extension.h#torch/all.h#'

# Stays in the work directory, which the natten outputs inherit
cmake -S "${RECIPE_DIR}/kernels" -B build-kernels ${CMAKE_ARGS} \
    -DNATTEN_CSRC="${SRC_DIR}/csrc" \
    -DNATTEN_CUDA_ARCHS="${NATTEN_CUDA_ARCHS}" \
    -DTORCH_INCLUDE_DIRS="${PREFIX}/include;${PREFIX}/include/torch/csrc/api/include"
cmake --build build-kernels -j"${NATTEN_N_WORKERS}"
