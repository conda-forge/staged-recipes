#!/bin/bash

target=$PREFIX/opt/maven
mkdir -p $target

cp -r * $target
cd $PREFIX/bin
ln -s ../opt/maven/bin/* .
