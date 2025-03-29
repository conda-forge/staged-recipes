#!/bin/bash

set -eu

export MAX_JOBS=1
export TORCH_CUDA_ARCH_LIST="7.0;8.0;9.0"

"$PYTHON" -m pip install . -vv
