#!/bin/bash

PY_INC=`$PYTHON -c "from distutils import sysconfig; print (sysconfig.get_python_inc(0, '$PREFIX'))"`
mkdir conda-build
cd conda-build

if [ `uname` = "Linux" ]; then
    export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
fi

cmake -G "Ninja" \
    -D Python_ADDITIONAL_VERSIONS="${PY_VER}" \
    -D PYTHON_EXECUTABLE="$PYTHON" \
    -D PYTHON_INCLUDE_DIR="${PY_INC}" \
    -D BOOST_ROOT="$PREFIX" \
    -D Boost_NO_SYSTEM_PATHS=ON \
    -D Boost_NO_BOOST_CMAKE=ON \
    -D CMAKE_SYSTEM_PREFIX_PATH="$PREFIX" \
    -D CMAKE_INSTALL_PREFIX="$PREFIX" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_SHARED_LINKER_FLAGS="-L$PREFIX/lib" \
    -D UNITTESTS=OFF \
    ..

ninja
ninja install

# python bindings are installed in some non-default location... copy them
cp -a $PREFIX/lib/BornAgain-*/bornagain ${SP_DIR}
cp -a $PREFIX/lib/BornAgain-*/*.py ${SP_DIR}
cp -a  $PREFIX/lib/BornAgain-*/*.so ${SP_DIR}

cd ..
