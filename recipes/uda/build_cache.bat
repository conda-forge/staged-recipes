@echo off

:: Configure Portable XDR
cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
    -DBUILD_SHARED_LIBS=OFF ^
    -B build\xdr -S "%SRC_DIR%\extlib"  || exit /b 1

:: Build and install Portable XDR
cmake --build build\xdr --target install --config Release || exit /b 1


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
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DXDR_LIBRARIES="%LIBRARY_LIB%\xdr.lib" ^
    -DXDR_INCLUDE_DIR="%LIBRARY_INC%\rpc" ^
    -B build\uda -S "%SRC_DIR%" || exit /b 1

:: Build and install
cmake --build build\uda --target install --config Release || exit /b 1
