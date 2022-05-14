set -exou

mkdir build
pushd build
cmake $CMAKE_ARGS -DDOCUMENTATION=OFF -DWITH_CJSON=OFF ..
make -j $CPU_COUNT
make install
