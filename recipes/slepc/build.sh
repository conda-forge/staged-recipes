#!/bin/bash

export PETSC_DIR=$PREFIX
export SLEPC_DIR=$SRC_DIR
export SLEPC_ARCH=installed-arch-conda-c-opt

python2 ./configure \
  --prefix=$PREFIX

sedinplace() { [[ $(uname) == Darwin ]] && sed -i "" $@ || sed -i"" $@; }
sedinplace s%$SLEPC_DIR%\${SLEPC_DIR}%g $SLEPC_ARCH/include/slepc*.h
sedinplace s%$PETSC_DIR%\${PETSC_DIR}%g $SLEPC_ARCH/include/slepc*.h

make
make install

rm -fr $PREFIX/bin
rm -fr $PREFIX/share
rm -fr $PREFIX/lib/lib$PKG_NAME.*.dylib.dSYM
rm -f  $PREFIX/lib/$PKG_NAME/conf/files
rm -f  $PREFIX/lib/$PKG_NAME/conf/*.py
rm -f  $PREFIX/lib/$PKG_NAME/conf/*.log
rm -f  $PREFIX/lib/$PKG_NAME/conf/RDict.db
rm -f  $PREFIX/lib/$PKG_NAME/conf/*BuildInternal.cmake
find   $PREFIX/include -name '*.html' -delete
