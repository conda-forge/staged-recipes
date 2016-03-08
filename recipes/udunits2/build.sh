#!/bin/bash

if [[ $(uname) != Darwin ]]; then
    yum install -y automake libtool texinfo
fi


if [ ! -f configure ];
then
   autoreconf -i --force
fi

if [[ $(uname) != Darwin ]]; then
    export LDFLAGS="-L$PREFIX/lib"
    export CFLAGS="-fPIC -I$PREFIX/include"
fi

./configure --prefix=$PREFIX

make
make check
make install

if [[ $(uname) == Darwin ]]; then
    cp ${RECIPE_DIR}/patchbinary.py ${PREFIX}/
    echo ${PREFIX} > ${PREFIX}/build_prefix.a
fi
