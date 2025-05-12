#!/bin/bash -e
export MAX_JOBS=1
# needed to find libcrypt headers
export CPATH=${BUILD_PREFIX}/include
export VLLM_TARGET_DEVICE="cuda"

${PYTHON} use_existing_torch.py
${PYTHON} -m pip install . --no-deps -vv --no-deps --no-build-isolation
