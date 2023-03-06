#!/bin/bash

# Needed to find argtable, dont know why it is not automatic...
cd conda_build/argtable2
./build.sh
export CFLAGS="-I$PREFIX/include"
cd ../..

# Install tools
$PYTHON compile_all.py
mkdir $PREFIX/bin/ete3_apps/

# Compile Slr in linux
SYS=`uname`
echo $SYS
if [ "$SYS" == "Linux" ]; then
    (cd src/slr/src/ &&
        make clean &&
        make BLASDIR=$PREFIX/lib CC=/usr/bin/gcc LD=/usr/bin/ld &&
        cp ../bin/Slr ../../../bin;
)


fi;

cp -r bin/ $PREFIX/bin/ete3_apps/
echo %VERSION% > $PREFIX/bin/ete3_apps/__version__