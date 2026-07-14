@echo on

cmake %CMAKE_ARGS% ^
  -S . ^
  -B build ^
  -G Ninja ^
  -C cmake/caches/PredefinedParams.cmake ^
  -DCMAKE_BUILD_TYPE=Release ^
  "-DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR=lib ^
  "-DDIRECTX_HEADER_INCLUDE_DIR=%LIBRARY_INC%" ^
  "-DSPIRV-Headers_SOURCE_DIR=%LIBRARY_PREFIX%" ^
  -DDXC_USE_SYSTEM_SPIRV_TOOLS=ON ^
  -DHLSL_ENABLE_FIXED_VER=ON ^
  -DHLSL_SUPPORT_QUERY_GIT_COMMIT_INFO=OFF ^
  -DHLSL_INCLUDE_TESTS=OFF ^
  -DSPIRV_BUILD_TESTS=OFF ^
  -DLLVM_INCLUDE_TESTS=OFF ^
  -DCLANG_INCLUDE_TESTS=OFF ^
  -DLLVM_ENABLE_ZLIB=FORCE_ON
if errorlevel 1 exit /b 1

cmake --build build --target install-distribution --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1
