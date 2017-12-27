#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
cd ghc-8.2.2
ls
if [ `uname` == Darwin ]
then
    export DYLD_LIBRARY_PATH="${PREFIX}/lib"
    export STACK_ROOT="${SRC_DIR}/s"
    ./configure --prefix=$PREFIX
    make
    make install
else
   ./configure --prefix=$PREFIX
   make
   make install
fi
#cleanup
rm -r .stack-work

