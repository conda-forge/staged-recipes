
pyver=$($PYTHON --version)
pyver=${pyver//Python /}

mkdir -p build

cmake \
    -H. \
    -Bbuild \
    -DPYTHON_VERSION=${pyver} \
    -DFORCE_OPENMP=YES \
    -DCMAKE_VERBOSE_MAKEFILE=ON

pushd build
make VERBOSE=1 _ccllib
popd

${PYTHON} -m pip install . -vv
