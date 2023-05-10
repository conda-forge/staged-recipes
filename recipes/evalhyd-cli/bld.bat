cmake -G "Ninja" ^
      -B build/ ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_LIBDIR=lib ^
      -D CMAKE_BUILD_TYPE=Release
if %ERRORLEVEL% neq 0 exit 1

cmake --build build/ --parallel %CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

cmake --install build/ --prefix %LIBRARY_PREFIX%
if %ERRORLEVEL% neq 0 exit 1
