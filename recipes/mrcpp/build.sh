BUILD_TYPE="Release"

if [ "$parallel" == "openmp" ]; then
    OMP_SUPPORT=ON
    MPI_SUPPORT=OFF
elif [ "$parallel" == "hybrid" ]; then
    OMP_SUPPORT=ON
    MPI_SUPPORT=ON
else
    MPI_SUPPORT=OFF
    OMP_SUPPORT=OFF
fi

# configure
cmake \
  -H${SRC_DIR} \
  -Bbuild \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DENABLE_OPENMP=${OMP_SUPPORT} \
  -DENABLE_MPI=${MPI_SUPPORT} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DBUILD_STATIC_LIBS=False \
  -DENABLE_TESTS=True

# build
cd build
cmake --build . -- -j${CPU_COUNT}

# test
ctest -j${CPU_COUNT} --output-on-failure --verbose

# install
cmake --build . --target install -- -j${CPU_COUNT}
