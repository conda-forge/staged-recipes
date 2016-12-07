#!/bin/bash
# cd build
# cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} ./cmake
make -j4
make install

# glew installs to /lib64 in some occasions, but conda only uses /lib and
# also changes the rpath to these locations. If this is the case, move the
# libraries from /lib64 to /lib
if [ -f "${PREFIX}/lib64/libGLEW.so" ]; then
    mv "${PREFIX}/lib64/libGLEW.so" "${PREFIX}/lib/libGLEW.so"
fi

if [ -f "${PREFIX}/lib64/libGLEW.a" ]; then
    mv "${PREFIX}/lib64/libGLEW.a" "${PREFIX}/lib/libGLEW.a"
fi

if [ -f "${PREFIX}/lib64/pkgconfig/glew.pc" ]; then
    mv "${PREFIX}/lib64/pkgconfig/glew.pc" "${PREFIX}/lib/pkgconfig/glew.pc"

    # The generated pkg-config file references /lib64
    sed -i s/lib64/lib/ ${PREFIX}/lib/pkgconfig/glew.pc
fi

# Don't install the cmake files for 2 reasons:
#   1 - cmake already provides a FindGLEW.cmake
#   2 - the generated file contains hardcoded paths to /usr/lib64, to reference the files
#       GL.so and GLU.so libraries.
#       Other distros don't use this nomenclature (eg.: Ubuntu) making these files unsuitable for use
#       in other distros other than redhat/centos.
if [ -d "${PREFIX}/lib64/cmake/glew/" ]; then
    rm -rf $PREFIX/lib64/cmake/glew/
fi

# Ensures that lib64 is empty
if [ -d "${PREFIX}/lib64/" ]; then
    if [ "$(ls -A ${PREFIX}/lib64)" ]; then
        rm -rf "${PREFIX}/lib64/"
    fi
fi