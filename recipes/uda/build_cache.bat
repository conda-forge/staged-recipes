@echo off

:: Configure Portable XDR
cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -B build\xdr -S "%SRC_DIR%\extlib"  || exit /b 1

:: Build and install Portable XDR
cmake --build build\xdr --target install  || exit /b 1

:: Set environment variables for UDA client
set XDR_LIBRARIES=%PREFIX%\lib
set XDR_INCLUDE_DIR=%PREFIX%\include

:: === Build & Install UDA client ===
:: Configure and build
cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -DBUILD_SHARED_LIBS=ON ^
    -DSSLAUTHENTICATION=ON ^
    -DCLIENT_ONLY=ON ^
    -DSERVER_ONLY=OFF ^
    -DENABLE_CAPNP=ON ^
    -DNO_MEMCACHE=ON ^
    -DNO_WRAPPERS=OFF ^
    -DNO_CXX_WRAPPER=OFF ^
    -DNO_IDL_WRAPPER=ON ^
    -DNO_PYTHON_WRAPPER=OFF ^
    -DNO_JAVA_WRAPPER=OFF ^
    -DFAT_IDL=OFF ^
    -DNO_CLI=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -B build\uda -S "%SRC_DIR%" || exit /b 1

:: Build and install
cmake --build build\uda --target install || exit /b 1
