set -ex

# Target the same CUDA archs as conda-forge pytorch package
# https://github.com/conda-forge/pytorch-cpu-feedstock/blob/main/recipe/build_pytorch.sh
# Number of CUDA archs reduced to fit CI resources
if [[ ${cuda_compiler_version} != "None" ]]; then
    if [[ ${cuda_compiler_version} == 11.8 ]]; then
        export TORCH_CUDA_ARCH_LIST="5.0;8.9+PTX"
    elif [[ ${cuda_compiler_version} == 12.0 ]]; then
        export TORCH_CUDA_ARCH_LIST="5.0;7.0;8.0;9.0+PTX"
    else
        echo "Unsupported CUDA compiler version. Edit build.sh to add target CUDA archs."
        exit 1
    fi
    export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
