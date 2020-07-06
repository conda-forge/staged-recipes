#!/bin/sh


cmake src
make -j ${CPU_COUNT}

cp parSMURF1 $PREFIX/
cp parSMURFn $PREFIX/
