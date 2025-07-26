set -ex

# Target the same CUDA archs as conda-forge pytorch package
# https://github.com/conda-forge/pytorch-cpu-feedstock/blob/main/recipe/build_pytorch.sh
# Number of CUDA archs reduced to fit CI resources
if [[ ${cuda_compiler_version} != "None" ]]; then
    if [[ ${cuda_compiler_version} == 12.9 ]]; then
        # __hfma2 is only defined for arch 5.3+, so we can't start from 5.0
        # https://github.com/pytorch/ao/issues/2611
        export TORCH_CUDA_ARCH_LIST="5.3;6.0;7.0;7.5;8.0;8.6;8.9;9.0;10.0;12.0+PTX"
    elif [[ ${cuda_compiler_version} == 12.6 ]]; then
        export TORCH_CUDA_ARCH_LIST="5.3;6.0;7.0;7.5;8.0;8.6;8.9"
    else
        echo "Unsupported CUDA compiler version. Edit build.sh to add target CUDA archs."
        exit 1
    fi
    export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
    export USE_CUDA=1
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
