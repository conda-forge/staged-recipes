#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

PYPY3_SRC_DIR=$SRC_DIR/pypy3

if [ $(uname) == Darwin ]; then
    export CC=$CLANG
    export PYTHON=$SRC_DIR/pypy2-osx/bin/pypy
fi

if [ $(uname) == Linux ]; then
   # Some ffi deps are expecting 'cc', so we give it to them.
   export FAKE_CC_LINK=${PREFIX}/bin/cc
   ln -s $CC $FAKE_CC_LINK
   export PATH="${PATH}/bin:${PATH}"

   export CC=$GCC
   export PYTHON=${PREFIX}/bin/python

   # Prevent linking to libncurses, forces libncursesw.
   rm -f ${PREFIX}/lib/libncurses.*

    # PyPy translation looks for this.
    export PYPY_LOCALBASE="$PREFIX"

    export LIBRARY_PATH=${PREFIX}/lib
    export C_INCLUDE_PATH=${PREFIX}/include
    export CPATH=${PREFIX}/include
fi

GOAL_DIR=$PYPY3_SRC_DIR/pypy/goal
RELEASE_DIR=$PYPY3_SRC_DIR/pypy/tool/release

PKG_NAME=pypy3
BUILD_DIR=${PREFIX}/../build
TARGET_DIR=${PREFIX}/../target
ARCHIVE_NAME="${PKG_NAME}-${PKG_VERSION}"

# Build PyPy.
cd $GOAL_DIR
${PYTHON} ../../rpython/bin/rpython --make-jobs 4 --shared -Ojit targetpypystandalone.py

if [ $(uname) == Darwin ]; then
    # Temporally set the @rpath of the generated PyPy binary to ${PREFIX}.
    cp ./${PKG_NAME}-c ./${PKG_NAME}-c.bak
    ${INSTALL_NAME_TOOL} -add_rpath "${PREFIX}/lib" ./${PKG_NAME}-c
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
    ${INSTALL_NAME_TOOL} -rpath "${PREFIX}/lib" "@loader_path/../lib" $PREFIX/bin/pypy3
    rm $GOAL_DIR/${PKG_NAME}-c.bak
fi


if [ $(uname) == Linux ]; then
    # Show links.
    ldd $PREFIX/bin/pypy3
    ldd $PREFIX/bin/libpypy3-c.so

    # Move the so to lib folder.
    mv $PREFIX/bin/libpypy3-c.so $PREFIX/lib/libpypy3-c.so

    # Conda tries to `patchself` this file, which fails.
    rm -f $PREFIX/bin/pypy3.debug

    # Conda will complain if a symlink exists.
    rm -f $FAKE_CC_LINK
fi
