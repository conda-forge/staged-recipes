@echo on

cmake -G "Ninja" -B build -S . ^
      -D CMAKE_BUILD_TYPE="Release" ^
      -D BUILD_SHARED_LIBS=ON ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH=%LIBRARY_PREFIX% ^
      -D PASTIX_ORDERING_SCOTCH:BOOL=OFF
if %ERRORLEVEL% neq 0 exit 1

ninja -C build install