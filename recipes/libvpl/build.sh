set -ex

mkdir build
pushd build

cmake ${CMAKE_ARGS} ..

make -j${CPU_COUNT}

make install

# Don't install the examples
rm -rf ${PREFIX}/share/vpl/examples
