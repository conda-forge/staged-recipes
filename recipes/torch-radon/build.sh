set -ex

export TORCH_CUDA_ARCH_LIST="3.5 3.7 5.0 5.2 5.3 6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6+PTX"

$PYTHON -m pip install . -vv --no-deps
