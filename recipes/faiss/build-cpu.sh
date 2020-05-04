# Build vanilla version (no avx)
./configure --without-cuda
make
make -C python _swigfaiss.so

make -C python build

cd python

$PYTHON -m pip install . -vv
