mkdir build
cd build

cmake -G "NMake Makefiles" ^
      -D RAPIDJSON_HAS_STDSTRING=ON ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D RAPIDJSON_BUILD_TESTS=OFF ^
      -D RAPIDJSON_BUILD_EXAMPLES=OFF ^
      -D RAPIDJSON_BUILD_DOC=OFF ^
      -D CMAKE_VERBOSE_MAKEFILE=ON ^
      -D CMAKE_BUILD_TYPE=Release ^
      ..

if errorlevel 1 exit 1

nmake install

if errorlevel 1 exit 1
