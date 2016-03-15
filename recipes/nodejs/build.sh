if [ `uname` == Darwin ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.7
fi
./configure --prefix=$PREFIX
make -j$CPU_COUNT
make install
