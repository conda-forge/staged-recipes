#!/bin/bash

set -ex


for f in average bound interval normalize random range round; do
    cp $f $PREFIX/bin/num$f
done

for f in numgrep numprocess numsum; do
    cp $f $PREFIX/bin/
done
