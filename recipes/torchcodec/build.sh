if [[ ${cuda_compiler_version} != "None" ]]; then
   export ENABLE_CUDA=1
else
   export ENABLE_CUDA=0
fi

pip install . --no-deps --no-build-isolation -vv
