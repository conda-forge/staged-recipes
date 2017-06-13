#!/bin/bash

cd unix

if [ "$(uname)" == "Darwin" ]
then
    make macosx-64 -j${CPU_COUNT} || make macosx-64 -j${CPU_COUNT}
elif [ "$(uname)" == "Linux" ]
then
    make linux-64-thr -j${CPU_COUNT} || make linux-64-thr -j${CPU_COUNT}
fi

cd ..
cp compile/*/tachyon "$PREFIX/bin"
