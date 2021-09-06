#!/bin/bash

export QT_SELECT=5
export LUA_PACKAGE=lua

ln -s ${CXX} ${PREFIX}/bin/g++ || true
ln -s ${CXX} ${PREFIX}/bin/gcc || true

cd src
make IPEPREFIX=$PREFIX
make documentation IPEPREFIX=$PREFIX
make install IPEPREFIX=$PREFIX

rm -f ${PREFIX}/bin/gcc
rm -f ${PREFIX}/bin/g++
