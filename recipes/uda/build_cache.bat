@echo off

:: Configure Portable XDR
cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -D BUILD_SHARED_LIBS=OFF ^
    -B build\xdr -S "%SRC_DIR%\extlib"  || exit /b 1

:: Build and install Portable XDR
cmake --build build\xdr --target install --config Release || exit /b 1


:: === Build & Install UDA client ===
:: Configure and build
cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -D BUILD_SHARED_LIBS=ON ^
    -D SSLAUTHENTICATION=ON ^
    -D CLIENT_ONLY=ON ^
    -D SERVER_ONLY=OFF ^
    -D ENABLE_CAPNP=ON ^
    -D NO_MEMCACHE=ON ^
    -D NO_WRAPPERS=OFF ^
    -D NO_CXX_WRAPPER=OFF ^
    -D NO_IDL_WRAPPER=ON ^
    -D NO_PYTHON_WRAPPER=OFF ^
    -D NO_JAVA_WRAPPER=OFF ^
    -D FAT_IDL=OFF ^
    -D NO_CLI=OFF ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D XDR_LIBRARIES="%LIBRARY_LIB%\xdr.lib" ^
    -D XDR_INCLUDE_DIR="%LIBRARY_INC%\rpc" ^
    -B build\uda -S "%SRC_DIR%" || exit /b 1

:: Build and install
cmake --build build\uda --target install --config Release || exit /b 1
