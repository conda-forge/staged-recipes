#!/bin/bash

export CFLAGS=-I$PREFIX/include
export CPPFLAGS=$CFLAGS
export CXXFLAGS=$CFLAGS
export LDFLAGS=-L$PREFIX/lib

if [ $(uname) == Linux ]; then
    pushd $PREFIX/lib
    ln -s libtcl8.6.so libtcl.so
    ln -s libtk8.6.so libtk.so
    popd
fi

cd $SRC_DIR/pypy/goal
python ../../rpython/bin/rpython --opt=jit

cd $SRC_DIR/pypy/goal
PYTHONPATH=../.. python ../tool/build_cffi_imports.py

export BUILD_DIR=$(readlink -f $RECIPE_DIR/../build)
export TARGET_DIR=$(readlink -f $RECIPE_DIR/../target)
export ARCHIVE_NAME="${PKG_NAME}-${PKG_VERSION}"
mkdir -p $BUILD_DIR $TARGET_DIR

cd $SRC_DIR/pypy/tool/release
python ./package.py --builddir="$BUILD_DIR" --targetdir="$TARGET_DIR" --archive-name="$ARCHIVE_NAME"

# ---

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include_pypy
mkdir -p $PREFIX/lib_pypy
mkdir -p $PREFIX/lib-python
mkdir -p $PREFIX/site-packages

mv $BUILD_DIR/$ARCHIVE_NAME/bin/pypy* $PREFIX/bin/
mv $BUILD_DIR/$ARCHIVE_NAME/bin/libpypy* $PREFIX/lib/
mv $BUILD_DIR/$ARCHIVE_NAME/include/* $PREFIX/include_pypy/
mv $BUILD_DIR/$ARCHIVE_NAME/lib_pypy/* $PREFIX/lib_pypy/
mv $BUILD_DIR/$ARCHIVE_NAME/lib-python/* $PREFIX/lib-python/
mv $BUILD_DIR/$ARCHIVE_NAME/site-packages/* $PREFIX/site-packages/
