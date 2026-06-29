rm -rf build

cmake -S . ^
  -G Ninja ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=$PREFIX ^
  -DJRL_CMAKEMODULES_GENERATE_API_DOC=OFF ^
  -DJRL_CMAKEMODULES_BUILD_TESTS=OFF ^
  -DJRL_CMAKEMODULES_INSTALL_V2_ONLY=ON

cmake --build build
cmake --install build
