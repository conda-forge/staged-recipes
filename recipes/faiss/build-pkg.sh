CUDA_CONFIG_ARG=""
if [ ${cuda_compiler_version} != "None" ]; then
    CUDA_CONFIG_ARG="--with-cuda=${CUDA_HOME}"
else
    CUDA_CONFIG_ARG="--without-cuda"
fi

# Build vanilla version (no avx)
./configure --with-blas=-lblas --with-lapack=-llapack ${CUDA_CONFIG_ARG}

make -C python build

cd python

$PYTHON -m pip install . -vv
