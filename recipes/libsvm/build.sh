#!/bin/bash

make lib
# there is no make check or something similar and no make install

mkdir -p $PREFIX/share/licenses/libsvm $PREFIX/lib $PREFIX/include
install -m644 libsvm.so.* $PREFIX/lib/
install -m644 svm.h $PREFIX/include/svm.h
install -m644 COPYRIGHT $PREFIX/share/licenses/libsvm/LICENSE
ln -s libsvm.so.* $PREFIX/lib/libsvm.so
