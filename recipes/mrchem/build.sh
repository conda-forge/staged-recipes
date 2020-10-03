BUILD_TYPE="Release"
CXXFLAGS="${CXXFLAGS//-march=nocona}"
CXXFLAGS="${CXXFLAGS//-mtune=haswell}"

if [ -n "$mpi" ] & [ "$mpi" != "nompi" ]; then
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
  -DENABLE_ARCH_FLAGS=OFF \
  -DENABLE_MPI=${MPI_SUPPORT} \
  -DCMAKE_CXX_COMPILER=${CXX} \
  -DCMAKE_INSTALL_LIBDIR="lib" \
  -DPYMOD_INSTALL_LIBDIR="${SP_DIR#$PREFIX/lib}"


# build
cd build
cmake --build . -- -j${CPU_COUNT} -v -d stats

# unset so we can run tests
if [ "$(uname)" = "Linux" ]; then
  export OMPI_MCA_plm_rsh_agent=""
fi

# test
ctest -j${CPU_COUNT} --output-on-failure --verbose

# install
cmake --build . --target install -- -j${CPU_COUNT}
