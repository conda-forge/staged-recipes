#!/bin/bash

PY_INC=`$PYTHON -c "from distutils import sysconfig; print (sysconfig.get_python_inc(0, '$PREFIX'))"`

if [ "$OSX_ARCH" == "x86_64" ]; then
  export CXXFLAGS="$CXXFLAGS -std=c++11 -stdlib=libc++ -Wno-parentheses -Wno-logical-op-parentheses -Wno-format"
  export CFLAGS="$CFLAGS -Wno-parentheses -Wno-logical-op-parentheses -Wno-format"
fi
cmake \
    -D RDK_INSTALL_INTREE=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    -D RDK_BUILD_INCHI_SUPPORT=ON \
    -D RDK_BUILD_AVALON_SUPPORT=ON \
    -D RDK_USE_FLEXBISON=OFF \
    -D RDK_BUILD_CAIRO_SUPPORT=ON \
    -D RDK_BUILD_THREADSAFE_SSS=ON \
    -D RDK_TEST_MULTITHREADED=ON \
    -D CMAKE_SYSTEM_PREFIX_PATH="$PREFIX" \
    -D CMAKE_INSTALL_PREFIX="$PREFIX" \
    -D Python_ADDITIONAL_VERSIONS="${PY_VER}" \
    -D PYTHON_EXECUTABLE="$PYTHON" \
    -D PYTHON_INCLUDE_DIR="${PY_INC}" \
    -D PYTHON_NUMPY_INCLUDE_PATH="$SP_DIR/numpy/core/include" \
    -D BOOST_ROOT="$PREFIX" -D Boost_NO_SYSTEM_PATHS=ON \
    -D CMAKE_BUILD_TYPE=Release \
    .


make -j$CPU_COUNT
make install
