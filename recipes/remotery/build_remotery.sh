#!/bin/bash


# NOTE(jjerphan): those directories contain source of examples
# and of an application running in web browsers.
#
# We do not want to build those.
rm -Rf sample
rm -Rf vis

rm -rf build
mkdir build
cd build

echo "Building $PKG_NAME"

if [[ $PKG_NAME == "remotery" ]]; then
    cmake .. ${CMAKE_ARGS}              \
        -DCMAKE_INSTALL_PREFIX=$PREFIX  \
        -DCMAKE_PREFIX_PATH=$PREFIX     \
        -DREMOTERY_BUILD_SHARED=ON      \
        -DREMOTERY_BUILD_STATIC=OFF
elif [[ $PKG_NAME == "remotery-static" ]]; then
    cmake .. ${CMAKE_ARGS}              \
        -DCMAKE_INSTALL_PREFIX=$PREFIX  \
        -DCMAKE_PREFIX_PATH=$PREFIX     \
        -DREMOTERY_BUILD_SHARED=OFF     \
        -DREMOTERY_BUILD_STATIC=ON
fi

make

make install
