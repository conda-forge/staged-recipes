#!/bin/bash

if [[ $(uname) != Darwin ]]; then
    yum install -y gcc-java
fi

./configure --enable-java \
            --enable-cxx \
            --enable-python \
            --enable-csharp \
            --prefix=$PREFIX

make
make install
