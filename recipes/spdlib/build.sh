#!/bin/bash

if [ `uname` == Darwin ]; then
    export DYLD_FALLBACK_LIBRARY_PATH=$PREFIX/lib
else
    export LD_LIBRARY_PATH=$PREFIX/lib    
fi

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -D HDF5_INCLUDE_DIR=$PREFIX/include \
    -D HDF5_LIB_PATH=$PREFIX/lib \
    -D LIBLAS_INCLUDE_DIR=$PREFIX/include \
    -D LIBLAS_LIB_PATH=$PREFIX/lib \
    -D GSL_INCLUDE_DIR=$PREFIX/include \
    -D GSL_LIB_PATH=$PREFIX/lib \
    -D CGAL_INCLUDE_DIR=$PREFIX/include \
    -D CGAL_LIB_PATH=$PREFIX/lib \
    -D BOOST_INCLUDE_DIR=$PREFIX/include \
    -D BOOST_LIB_PATH=$PREFIX/lib \
    -D GDAL_INCLUDE_DIR=$PREFIX/include \
    -D GDAL_LIB_PATH=$PREFIX/lib \
    -D XERCESC_INCLUDE_DIR=$PREFIX/include \
    -D XERCESC_LIB_PATH=$PREFIX/lib \
    -D GMP_INCLUDE_DIR=$PREFIX/include \
    -D GMP_LIB_PATH=$PREFIX/lib \
    -D MPFR_INCLUDE_DIR=$PREFIX/include \
    -D MPFR_LIB_PATH=$PREFIX/lib \
    -D CMAKE_BUILD_TYPE=Release \
    .

make install -j$CPU_COUNT

# now Python bindings
cd python
cmake -D CMAKE_INSTALL_PREFIX=$STDLIB_DIR \
    -D CMAKE_BUILD_TYPE=Release \
    -D HDF5_INCLUDE_DIR=$PREFIX/include \
    -D HDF5_LIB_PATH=$PREFIX/lib \
    -D SPDLIB_IO_INCLUDE_DIR=$PREFIX/include \
    -D SPDLIB_IO_LIB_PATH=$PREFIX/lib \
    -D CMAKE_PREFIX_PATH=$PREFIX \
    .
make
make install

# now the 'ng' python bindings
cd ../ngpython
$PYTHON setup.py build --gdalinclude=$PREFIX/include \
    --boostinclude=$PREFIX/include \
    --gslinclude=$PREFIX/include \
    --cgalinclude=$PREFIX/include \
    --lasinclude=$PREFIX/include \
    --hdf5include=$PREFIX/include \
    --gdallib=$PREFIX/lib

$PYTHON setup.py install
cd ..
