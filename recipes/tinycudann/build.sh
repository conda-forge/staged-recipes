#!/bin/bash

set -exo pipefail

export TCNN_CUDA_ARCHITECTURES=70,80,90

cd bindings/torch
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
