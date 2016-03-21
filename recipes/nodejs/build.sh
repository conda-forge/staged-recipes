if [ "$ARCH" -eq "64" ]; then
    ARCH=x64
else
    ARCH=ia32
fi

if [ `uname` == Darwin ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.7
fi

./configure --prefix=$PREFIX --dest-cpu $ARCH
make -j$CPU_COUNT
make install
