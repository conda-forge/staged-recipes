#!/bin/sh
# See https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
declare -a CMAKE_PLATFORM_FLAGS
if [[ ${HOST} =~ .*darwin.* ]]; then
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  export LDFLAGS=$(echo "${LDFLAGS}" | sed "s/-Wl,-dead_strip_dylibs//g")
else
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

mkdir ../build && cd ../build

# Build the static libs
cmake \
  ${CMAKE_PLATFORM_FLAGS[@]} \
  -DCMAKE_BUILD_TYPE=RELWITHDEBINFO \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DDOWNLOAD_TEST_DATA=OFF \
  -DTEST_INSTALL=OFF \
  $SRC_DIR

make

# only install .a library files
cmake \
  -DCOMPONENT=RuntimeLibraries \
  -P cmake_install.cmake

# Build with shared libs
echo -e "\n\n\nBuilding shared libraries"
cmake \
   ${CMAKE_PLATFORM_FLAGS[@]} \
  -DNIFTI_INSTALL_NO_DOCS=FALSE
  -DBUILD_SHARED_LIBS=ON \
  $SRC_DIR

# Install all binaries, man files, cmake files, and headers
make install

# Run all tests that do not require downloaded data
ctest -LE NEEDS_DATA


