if [[ "$(uname)" == "Darwin" ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

make -j${NUM_CPUS}
make install PREFIX=$PREFIX
