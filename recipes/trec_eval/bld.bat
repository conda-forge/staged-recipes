mkdir build
cd build

cmake -LAH -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_LIBDIR:PATH=%LIBRARY_LIB% ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
       %SRC_DIR%
if %ERRORLEVEL% neq 0 exit 1
