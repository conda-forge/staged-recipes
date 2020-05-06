# Build vanilla version (no avx)
./configure --without-cuda

make -C python build

cd python

$PYTHON -m pip install . -vv
