# Build vanilla version (no avx, no gpu)
./configure --without-cuda --with-blas=-lblas --with-lapack=-llapack

make -C python build

cd python

$PYTHON -m pip install . -vv
