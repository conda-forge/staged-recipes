mkdir build_core install_core
cd build_core
export ISISROOT=$PWD

# Ensure the correct C++ compiler and standard library paths
export CXX=$CONDA_PREFIX/bin/clang++
export CXXFLAGS="$CXXFLAGS -I$CONDA_PREFIX/include/c++/v1"

# Set the macOS SDK path (optional)
export CMAKE_OSX_SYSROOT=$(xcrun --sdk macosx --show-sdk-path)

cmake -GNinja -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release -DISIS_BUILD_SWIG=ON -DCMAKE_INSTALL_PREFIX=../install_core ../isis/src/core
ninja core && ninja install
cd swig/python/
python setup.py install