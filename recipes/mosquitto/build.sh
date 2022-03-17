set -exou

mkdir build
pushd build
cmake -D WITH_CJSON=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make -j $CPU_COUNT
make install
