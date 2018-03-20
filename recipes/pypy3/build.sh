#!/bin/bash

export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="-I${PREFIX}/include"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

PYPY3_SRC_DIR=$SRC_DIR/pypy3

if [ $(uname) == Darwin ]; then
    export CC=clang
    export PYTHON=$SRC_DIR/pypy2-osx/bin/pypy

    # libffi doesn't look in the correct location. We modify a copy of it since it's a hard link to conda's file.
    # This is only relevant during the build, so we will put the original file back at the end.
    mv ${PREFIX}/lib/libffi.6.dylib ${PREFIX}/lib/libffi.6.dylib.bak
    cp ${PREFIX}/lib/libffi.6.dylib.bak ${PREFIX}/lib/libffi.6.dylib

    install_name_tool -id ${PREFIX}/lib/libffi.6.dylib ${PREFIX}/lib/libffi.6.dylib
fi

if [ $(uname) == Linux ]; then
   export CC=gcc
   export PYTHON=${PREFIX}/bin/python
fi

GOAL_DIR=$PYPY3_SRC_DIR/pypy/goal
RELEASE_DIR=$PYPY3_SRC_DIR/pypy/tool/release

BUILD_DIR=${PREFIX}/../build
TARGET_DIR=${PREFIX}/../target
ARCHIVE_NAME="${PKG_NAME}-${PKG_VERSION}"

# Build PyPy.
cd $GOAL_DIR
${PYTHON} ../../rpython/bin/rpython --make-jobs 4 --shared --cc=$CC -Ojit targetpypystandalone.py

if [ $(uname) == Darwin ]; then
    # Temporally set the @rpath of the generated PyPy binary to ${PREFIX}.
    cp ./${PKG_NAME}-c ./${PKG_NAME}-c.bak
    install_name_tool -add_rpath "${PREFIX}/lib" ./${PKG_NAME}-c
fi

# Build cffi imports using the generated PyPy.
PYTHONPATH=../.. ./${PKG_NAME}-c ../tool/build_cffi_imports.py

# Package PyPy.
cd $RELEASE_DIR
mkdir -p $TARGET_DIR

${PYTHON} ./package.py --targetdir="$TARGET_DIR" --archive-name="$ARCHIVE_NAME"

cd $TARGET_DIR
tar -xvf $ARCHIVE_NAME.tar.bz2

# Move all files from the package to conda's $PREFIX.
cp -r $TARGET_DIR/$ARCHIVE_NAME/* $PREFIX

if [ $(uname) == Darwin ]; then
    # Move the dylib to lib folder.
    mv $PREFIX/bin/libpypy3-c.dylib $PREFIX/lib/libpypy3-c.dylib

    # Change @rpath to be relative to match conda's structure.
    install_name_tool -rpath "${PREFIX}/lib" "@loader_path/../lib" $PREFIX/bin/pypy3
    rm $GOAL_DIR/${PKG_NAME}-c.bak

    # The original libffi, works, so there is no need to ship our patched version.
    mv ${PREFIX}/lib/libffi.6.dylib.bak ${PREFIX}/lib/libffi.6.dylib
fi


if [ $(uname) == Linux ]; then
    # Move the so to lib folder.
    mv $PREFIX/bin/libpypy3-c.so $PREFIX/lib/libpypy3-c.so

    # Conda tries to `patchself` this file, which fails.
    rm -f $PREFIX/bin/pypy3.debug
fi
