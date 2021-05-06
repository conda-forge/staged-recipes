#!/bin/sh

git submodule -q sync
git submodule -q update --init --recursive

cd libraries
make
install -d ${PREFIX}/lib/omlibrary
cp -r build/* ${PREFIX}/lib/omlibrary
