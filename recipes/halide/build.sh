# use clang c++
if [[ $(uname) == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    # don't use clang++
    export CXX=c++
fi
make -j${NUM_CPUS}
make install PREFIX=$PREFIX
