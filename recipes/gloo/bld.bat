mkdir build
cd build
if errorlevel 1 exit /b 1

:: libuv disabled because it is static linking without a patch

cmake -GNinja %CMAKE_ARGS%^
    -DBUILD_BENCHMARK=OFF^
    -DBUILD_SHARED_LIBS=ON^
    -DBUILD_TEST=OFF^
    -DCMAKE_BUILD_TYPE=Release^
    -DUSE_LIBUV=OFF^
    -DUSE_REDIS=ON^
    -DUSE_TCP_OPENSSL_LOAD=OFF^
    -DUSE_TCP_OPENSSL_LINK=%USE_TCP_OPENSSL%^
    %GLOO_CUDA_CMAKE_ARGS%^
    %SRC_DIR%
if errorlevel 1 exit /b 1

cmake --build . -j%CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install .
if errorlevel 1 exit /b 1
