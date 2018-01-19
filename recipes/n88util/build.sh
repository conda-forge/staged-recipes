
# Create build directory
mkdir build
cd build
BUILD_CONFIG=Release

# CMake
cmake .. \
	-G "Ninja" \
  -DCMAKE_BUILD_TYPE=$BUILD_CONFIG \
  -DCMAKE_PREFIX_PATH:PATH="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
	-DCMAKE_INSTALL_RPATH:PATH="${PREFIX}/lib" \
	-DENABLE_TESTING:BOOL=OFF \
	-DBUILD_SHARED_LIBS:BOOL=ON

# Compile and install!
ninja install
