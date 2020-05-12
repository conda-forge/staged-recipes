#!/bin/sh
set -ex

./bootstrap \
             --verbose \
             --prefix="${PREFIX}" \
             --no-system-libs \
             --no-qt-gui \
             --parallel=${CPU_COUNT} \
             -- \
             -DCMAKE_BUILD_TYPE:STRING=Release \
             -DCMAKE_FIND_ROOT_PATH="${PREFIX}" \
             -DCMAKE_INSTALL_RPATH="${PREFIX}/lib" \
             -DCURSES_INCLUDE_PATH="${PREFIX}/include" \
             -DBUILD_CursesDialog=OFF \
             -DCMAKE_USE_OPENSSL=OFF \
             -DCMake_HAVE_CXX_MAKE_UNIQUE:INTERNAL=FALSE \
             -DCMAKE_PREFIX_PATH="${PREFIX}"
             
# CMake automatically selects the highest C++ standard available

make install -j${CPU_COUNT}

