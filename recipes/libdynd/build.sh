#!/usr/bin/env sh

#pwd 
#ls
#cd "$RECIPE_DIR/.."

mkdir build
cd build
cmake \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    -DCMAKE_BUILD_TYPE=Release \
    -DDYND_INSTALL_LIB=ON \
    -DDYND_BUILD_BENCHMARKS=OFF \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" .. || exit 1

if [ $TRAVIS = true ]
then
    export NBUILDS=4
else
    export NBUILDS=$(($CPU_COUNT * 2))
fi

make -j$NBUILDS package || exit 1
make install || exit 1
