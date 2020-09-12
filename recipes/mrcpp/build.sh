BUILD_TYPE="Release"

if [[ ! -z "$mpi" && "$mpi" != "nompi" ]]; then
  export CXX=mpicxx
  MPI_SUPPORT=ON
else
  export CXX=$(basename ${CXX})
  MPI_SUPPORT=OFF
fi

# configure
cmake \
  -H${SRC_DIR} \
  -Bbuild \
  -GNinja \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
  -DENABLE_OPENMP=ON \
  -DENABLE_MPI=${MPI_SUPPORT} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DCMAKE_INSTALL_LIBDIR="lib" \
  -DBUILD_STATIC_LIBS=False \
  -DENABLE_TESTS=True

# build
cd build
cmake --build . -- -j${CPU_COUNT}

# test
ctest -j${CPU_COUNT} --output-on-failure --verbose

# install
cmake --build . --target install -- -j${CPU_COUNT}
