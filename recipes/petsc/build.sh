#!/bin/bash

export PETSC_DIR=$SRC_DIR
export PETSC_ARCH=arch-conda-c-opt

python2 ./configure \
  --with-fc=0 \
  --with-debugging=0 \
  --COPTFLAGS=-O3 \
  --CXXOPTFLAGS=-O3 \
  --LIBS=-Wl,-rpath,$PREFIX/lib \
  --with-blas-lapack-dir=$PREFIX \
  --with-cmake=0 \
  --with-hwloc=0 \
  --with-ssl=0 \
  --with-x=0 \
  --prefix=$PREFIX

sedinplace() { [[ $(uname) == Darwin ]] && sed -i "" $@ || sed -i"" $@; }
for path in $PETSC_DIR $PREFIX; do
    sedinplace s%$path%\${PETSC_DIR}%g $PETSC_ARCH/include/petsc*.h
done

make
make install

if [[ $(uname) == Darwin ]];
then
    library=$PREFIX/lib/lib$PKG_NAME.dylib
    pathlist=$(otool -l $library | grep ' path /' | awk '{print $2}')
    for path in $pathlist; do
        install_name_tool -delete_rpath $path $library
    done
else
    library=$PREFIX/lib/lib$PKG_NAME.so
fi
$RECIPE_DIR/replace-binary.py $(dirname $SRC_DIR) "" $library

rm -fr $PREFIX/bin
rm -fr $PREFIX/share
rm -fr $PREFIX/lib/lib$PKG_NAME.*.dylib.dSYM
rm -f  $PREFIX/lib/$PKG_NAME/conf/files
rm -f  $PREFIX/lib/$PKG_NAME/conf/*.py
rm -f  $PREFIX/lib/$PKG_NAME/conf/*.log
rm -f  $PREFIX/lib/$PKG_NAME/conf/RDict.db
rm -f  $PREFIX/lib/$PKG_NAME/conf/*BuildInternal.cmake
find   $PREFIX/include -name '*.html' -delete
