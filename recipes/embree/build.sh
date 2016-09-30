#!/bin/bash
set -e
cd lib
ln -s libembree.* libembree.so
cd ..
cp -rv * "${PREFIX}"
