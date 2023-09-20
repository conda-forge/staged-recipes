
if [ ${cuda_compiler_version} != "None" ]; then
    export TORCH_CUDA_ARCH_LIST=$(${PYTHON} -c "import torch; print(';'.join([f'{y[0]}.{y[1]}' for y in [x[3:] for x in torch._C._cuda_getArchFlags().split() if x.startswith('sm_')]]))")
fi

{{ PYTHON }} -m pip install . -vv
