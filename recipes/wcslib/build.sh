export CFLAGS='-fPIC'

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

if [ "$(uname)" == "Darwin" ]; then
    
    # Build for a fairly old mac to ensure portability
    
    export MACOSX_DEPLOYMENT_TARGET=10.6


./configure --prefix=$PREFIX

make

make install
