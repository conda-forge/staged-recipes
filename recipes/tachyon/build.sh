#!/bin/bash

cd unix
case "$(uname)" in
    Darwin) target=macosx-x86_64-thr;;
    Linux) target=linux-64-thr;;
esac

make $target -j$CPU_COUNT || make $target -j$CPU_COUNT

cd ..
cp compile/*/tachyon "$PREFIX/bin"
