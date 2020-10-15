git submodule update --init --recursive

mkdir build-conda
pushd build-conda

# this cause error in pybind11 cmake
#    #-DPYTHON_EXECUTABLE=$PREFIX/bin/python \

# for conda, pybind11 should detect the python installation correctly
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=$LIBRARY_LIB \
    ..

make -j4
make install

# there is no need to run  setup.py in this repo
# python package should has been built and installed to site-package by make install

popd
