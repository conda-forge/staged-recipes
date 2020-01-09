#!/usr/bin/env bash
 # Enable bash strict mode
 # http://redsymbol.net/articles/unofficial-bash-strict-mode/

 set -ex

./configure --disable-debug --disable-dependency-tracking --prefix=${PREFIX}  --disable-freetypetest \
            --with-glut-inc=/dev/null --with-glut-lib=/dev/null

make install
