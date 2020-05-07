CUDA_CONFIG_ARG=""
if [ ${cuda_compiler_version} != "None" ]; then
    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
fi

# Build vanilla version (no avx)
./configure --without-cuda --with-blas=-lblas --with-lapack=-llapack ${CUDA_CONFIG_ARG}

[[ "$target_platform" == "win-64" ]] && patch_libtool

make -C python build

cd python

$PYTHON -m pip install . -vv
