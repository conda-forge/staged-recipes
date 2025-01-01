@echo on

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -B build \
  -DBUILD_SHARED_LIBS=ON

cmake --build build --parallel --config Release

cmake --install build --config Release
