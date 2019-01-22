#!/bin/bash

mkdir -p $PREFIX/bin
mv pandoc-crossref $PREFIX/bin
if [ $(uname) == Darwin ]; then
    mv pandoc-crossref.1 $PREFIX/bin
fi
