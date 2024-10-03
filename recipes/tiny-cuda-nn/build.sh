#!/bin/bash

set -exo pipefail

export TCNN_CUDA_ARCHITECTURES=70,80,90

python -m pip install . -vv --no-deps --no-build-isolation
