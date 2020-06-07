SHORT_OS_STR=$(uname -s)
if [ "${SHORT_OS_STR:0:5}" == "Linux" ]; then
    OPENMP="-DZFP_WITH_OPENMP=1"
fi
if [ "${SHORT_OS_STR}" == "Darwin" ]; then
    OPENMP=""
fi
mkdir build
cd build
cmake -LAH \
    -DCMAKE_BUILD_TYPE="Release"             \
    -DCMAKE_PREFIX_PATH=${PREFIX}            \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}         \
    -DCMAKE_INSTALL_LIBDIR="lib"             \
    -DBUILD_ZFPY=ON                          \
    -DBUILD_UTILITIES=ON                     \
    -DBUILD_CFP=ON                           \
    ${OPEN_MP}                               \
    ..

make -j ${CPU_COUNT}
make install
