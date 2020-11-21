#!/bin/bash

PYPY3_SRC_DIR=$SRC_DIR/pypy3

if [[ "$target_platform" == "osx-64" ]]; then
    export CC=$CLANG
    export PYTHON=${BUILD_PREFIX}/bin/python
fi

if [[ "$target_platform" == "linux"* ]]; then
   export CC=$GCC
   export PYTHON=${BUILD_PREFIX}/bin/python

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

PYPY_PKG_NAME=pypy3
BUILD_DIR=${PREFIX}/../build
TARGET_DIR=${PREFIX}/../target
ARCHIVE_NAME="${PYPY_PKG_NAME}-${PKG_VERSION}"

# Build PyPy.
cd $GOAL_DIR
${PYTHON} ../../rpython/bin/rpython --make-jobs ${CPU_COUNT} --shared -Ojit targetpypystandalone.py

if [[ "$target_platform" == "osx-64" ]]; then
    # Temporally set the @rpath of the generated PyPy binary to ${PREFIX}.
    cp ./${PYPY_PKG_NAME}-c ./${PYPY_PKG_NAME}-c.bak
    ${INSTALL_NAME_TOOL} -add_rpath "${PREFIX}/lib" ./${PYPY_PKG_NAME}-c
fi

# Build cffi imports using the generated PyPy.
PYTHONPATH=../.. ./${PYPY_PKG_NAME}-c ../../lib_pypy/pypy_tools/build_cffi_imports.py

# Package PyPy.
cd $RELEASE_DIR
mkdir -p $TARGET_DIR

${PYTHON} ./package.py --targetdir="$TARGET_DIR" --archive-name="$ARCHIVE_NAME"

cd $TARGET_DIR
tar -xvf $ARCHIVE_NAME.tar.bz2

# Move all files from the package to conda's $PREFIX.
cp -r $TARGET_DIR/$ARCHIVE_NAME/* $PREFIX

if [[ "$target_platform" == "osx-64" ]]; then
    # Move the dylib to lib folder.
    mv $PREFIX/bin/libpypy3-c.dylib $PREFIX/lib/libpypy3-c.dylib

    # Change @rpath to be relative to match conda's structure.
    ${INSTALL_NAME_TOOL} -rpath "${PREFIX}/lib" "@loader_path/../lib" $PREFIX/bin/pypy3
    rm $GOAL_DIR/${PYPY_PKG_NAME}-c.bak
fi


if [[ "$target_platform" == "linux"* ]]; then
    # Show links.
    ldd $PREFIX/bin/pypy3
    ldd $PREFIX/bin/libpypy3-c.so

    # Move the so to lib folder.
    mv $PREFIX/bin/libpypy3-c.so $PREFIX/lib/libpypy3-c.so

    # Conda tries to `patchelf` this file, which fails.
    rm -f $PREFIX/bin/pypy3.debug
fi

# Move the generic file name to somewhere that's specific to pypy
mv $PREFIX/README.rst $PREFIX/lib_pypy/
# License is packaged separately
rm $PREFIX/LICENSE

# Make sure the site-packages dir match with cpython
PY_VERSION=$(echo $PKG_NAME | cut -c 5-)
mkdir -p $PREFIX/lib/python${PY_VERSION}/site-packages
mv $PREFIX/site-packages/README $PREFIX/lib/python${PY_VERSION}/site-packages/
rm -rf $PREFIX/site-packages
ln -sf $PREFIX/lib/python${PY_VERSION}/site-packages $PREFIX/site-packages

# Build the cache for the standard library
timeout 60m pypy3 -m test --pgo -j${CPU_COUNT} || true;
cd $PREFIX/lib-python
pypy3 -m compileall . || true;
cd $PREFIX/lib_pypy
pypy3 -m compileall . || true;
