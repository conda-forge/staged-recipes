#!/bin/bash

set -exo pipefail

export TORCH_CUDA_ARCH_LIST="7.0;8.0;9.0"

python -m pip install . -vv --no-deps --no-build-isolation
