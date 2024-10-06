#!/bin/sh

rm -rf build
mkdir build
cd build
cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING:BOOL=ON \
      -DBUILD_SHARED_LIBS:BOOL=ON \
      -DNO_EXAMPLES:BOOL=OFF \
      -DNO_TUTORIALS:BOOL=OFF \
      -DNO_REGRESSION:BOOL=OFF \
      -DNO_PTEX:BOOL=ON \
      -DNO_DOC:BOOL=ON \
      -DNO_OMP:BOOL=ON \
      -DNO_TBB:BOOL=OFF \
      -DNO_CUDA:BOOL=ON \
      -DNO_OPENCL:BOOL=ON \
      -DNO_CLEW:BOOL=ON \
      -DNO_OPENGL:BOOL=ON \
      -DNO_METAL:BOOL=ON \
      -DNO_MACOS_FRAMEWORK:BOOL=ON \
      -DNO_DX=ON \
      -DNO_TESTS:BOOL=OFF \
      -DNO_GLTESTS:BOOL=OFF \
      -DNO_GLEW:BOOL=ON \
      -DNO_GLFW:BOOL=ON \
      -DNO_GLFW_X11:BOOL=ON

cmake --build . --config Release

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --output-on-failure -C Release
fi

# Enabling tests results in test and examples being installed,
# so after running the tests we disable them
cmake -DNO_EXAMPLES:BOOL=ON \
      -DNO_TUTORIALS:BOOL=ON \
      -DNO_REGRESSION:BOOL=ON .

cmake --build . --config Release --target install

