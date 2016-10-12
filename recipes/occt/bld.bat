mkdir build
cd build


cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_PREFIX_PATH=%PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D3DPARTY_DIR=%LIBRARY_PREFIX% ^
    -D3DPARTY_TCL_DIR=%LIBRARY_PREFIX% ^
    -D3DPARTY_TCL_DLL_DIR=%LIBRARY_BIN% ^
    -D3DPARTY_TCL_INCLUDE_DIR=%LIBRARY_INC% ^
    -D3DPARTY_TCL_LIBRARY_DIR=%LIBRARY_LIB% ^
    -D3DPARTY_TK_DIR=%LIBRARY_PREFIX% ^
    -D3DPARTY_TK_DLL_DIR=%LIBRARY_BIN% ^
    -D3DPARTY_TK_INCLUDE_DIR=%LIBRARY_INC% ^
    -D3DPARTY_TK_LIBRARY_DIR=%LIBRARY_LIB% ^

msbuild /m