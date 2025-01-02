@echo on

cmake %SRC_DIR% ^
  %CMAKE_ARGS% ^
  -B build ^
  -DBUILD_SHARED_LIBS=ON ^
  -DWITH_CUDA_BACKEND=OFF ^
  -DWITH_OPENCL_BACKEND=OFF ^
  -DWITH_ROCM_BACKEND=OFF

cmake --build build --parallel --config Release

cmake --install build --config Release
