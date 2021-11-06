#!/bin/bash

set -ex


for f in average bound interval normalize random range round; do
    cp $f $PREFIX/bin/num$f
    pod2man $f > num$f.1
    cp num$f.1 $PREFIX/share/man/man1/
done

for f in numgrep numprocess numsum; do
    cp $f $PREFIX/bin/
    pod2man $f > $f.1
    cp num$f.1 $PREFIX/share/man/man1/
done
