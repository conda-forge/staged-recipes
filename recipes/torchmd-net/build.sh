
# Output format from torch._C._cuda_getArchFlags(): 'sm_35 sm_50 sm_60 sm_61 sm_70 sm_75 sm_80 sm_86 compute_86'
# We need to turn this into: "3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6" for TORCH_CUDA_ARCH_LIST (which overrides CMake-native option)
# There is a higher level function, called torch.cuda.get_arch_list, but it returns an empty list when there is no GPU available.
# Should that fail, this could be used instead:
# $ cuobjdump $(find $CONDA_PREFIX -name "libtorch_cuda.so")  | grep arch | awk '{print $3}' | sort | uniq | sed 's+sm_\([0-9]\)\([0-9]\)+\1.\2+g' | tr '\n' ';'
if [ ${cuda_compiler_version} != "None" ]; then
    export TORCH_CUDA_ARCH_LIST=$(${PYTHON} -c "import torch; print(';'.join([f'{y[0]}.{y[1]}' for y in [x[3:] for x in torch._C._cuda_getArchFlags().split() if x.startswith('sm_')]]))")
fi

$PYTHON -m pip install . -vv
