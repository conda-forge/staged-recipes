#!/bin/sh

mkdir build && cd build

echo "*******************************************"
which cython
cython --version
echo "*******************************************"
echo "PYTHON is $PYTHON  - ${PY_VER}"
which $PYTHON
$PYTHON --version
$PYTHON -c "import cython; print(cython.__version__)"
echo "*******************************************"
which python
python --version
python -c "import cython; print(cython.__version__)"
echo "*******************************************"


cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DPython_ADDITIONAL_VERSIONS="${PY_VER}" \
  -DPYTHON_EXECUTABLE="$PYTHON" \
  -DWITH_GUDHI_PYTHON=OFF \
  ..

# install include files and utils
make install -j${CPU_COUNT}

# install the python package
cmake -DWITH_GUDHI_PYTHON=ON .
cd cython
$PYTHON setup.py install

