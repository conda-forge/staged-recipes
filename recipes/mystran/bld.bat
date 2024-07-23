cmake -G "MinGW Makefiles" -B build -S . ^
      -D CMAKE_BUILD_TYPE="Release" ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH=%LIBRARY_PREFIX%

mingw32-make -C build install
copy ..\Binaries\mystran %LIBRARY_PREFIX%\bin\mystran