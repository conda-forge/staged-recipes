#!/bin/sh

[[ -z "$DEBUG_BUILD" ]] && DEBUG_BUILD=false

CMAKE_EXTRA=""

export ENV="$BUILD_PREFIX"

export PATH="$ENV/bin:$PATH"

export PYTHON="`which python`"

if $DEBUG_BUILD; then
    export CPPFLAGS="`echo $CPPFLAGS|sed 's/-D_FORTIFY_SOURCE=2//g'`"
    
    CMAKE_EXTRA="$CMAKE_EXTRA -DCMAKE_BUILD_TYPE=Debug"
    CMAKE_EXTRA="$CMAKE_EXTRA -DINSTALLER_OMIT_MAPS=ON"
else
    CMAKE_EXTRA="$CMAKE_EXTRA -DCMAKE_BUILD_TYPE=Release"
fi

export CPPFLAGS=" \
    $CPPFLAGS \
    -Wno-unused-function \
    -Wno-conversion-null \
    -Wno-deprecated-declarations \
    -Wno-catch-value \
    -Wno-unknown-warning-option \
    "

export CPPFLAGS="-isystem $ENV/include/freetype2 $CPPFLAGS"

export CPPFLAGS="$CPPFLAGS -isystem $ENV/include"

export CXXFLAGS="$CXXFLAGS $CPPFLAGS"
export CFLAGS="$CFLAGS $CPPFLAGS"

unset CMAKE_ARGS
unset CMAKE_PREFIX_PATH

SP_DIR="`python -c 'import site; print(site.getsitepackages()[0].replace(\"'$BUILD_PREFIX'\", \"'$PREFIX'\"))'`"

unzip -d include buildutils/GTE.zip

if [ ! -d "build" ]; then
    mkdir build
fi
cd build

cmake .. \
    -DCONDA_BUILD=ON \
    -DBUILD_PYTHON=ON \
    -DBUILD_DOC=ON \
    -DBUILD_UTL=OFF \
    -DBUILD_GUI=OFF \
    -DBUILD_OSP=OFF \
    -DPython_EXECUTABLE="$PYTHON" \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    $CMAKE_EXTRA \



make -j$(($CPU_COUNT+1))
make doc
make install

