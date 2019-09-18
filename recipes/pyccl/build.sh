
pyver=`${PYTHON} -c "import sys; print('%d.%d.%d' % (sys.version_info[0], sys.version_info[1], sys.version_info[2]))"`

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
