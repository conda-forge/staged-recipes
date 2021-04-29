# TODO: Enable tests, fix https://jugit.fz-juelich.de/IBG-1/ModSim/cadet/cadet-docker/-/issues/1
# TODO: Figure out the right install prefix

echo "BUILD PREFIX $BUILD_PREFIX"
mkdir build && cd build
cmake \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_CADET_MEX=OFF \
    -DENABLE_TESTS=OFF \
    ..
make install -j $CPU_COUNT
