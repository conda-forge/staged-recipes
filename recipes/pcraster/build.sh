mkdir build && cd build

NUMPY_INCLUDE=$(python -c 'import numpy; print(numpy.get_include())')

export CXXFLAGS="-I$NUMPY_INCLUDE $CXXFLAGS"

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DPYTHON_EXECUTABLE=$PREFIX/bin/python3 ..
make -j$CPU_COUNT
make install
