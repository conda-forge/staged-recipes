setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

cmake -G "NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE:STRING="Release" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON ^
      -DSTATIC_LIB:BOOL=ON ^
      -DSHARED_LIB:BOOL=ON ^
      "%SRC_DIR%"
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

ctest -C release
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1

del %LIBRARY_BIN%\msvc*.dll
