
mkdir build
cd build

REM Make shared libs
cmake -G"Ninja" ^
      %CMAKE_ARGS% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_LIBRARY_PATH=%LIBRARY_LIB% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_FIND_FRAMEWORK=NEVER ^
      -DCMAKE_FIND_APPBUNDLE=NEVER ^
      -DBUILD_SHARED_LIBS=ON ^
      -DBUILD_STATIC_LIBS=ON ^
      %SRC_DIR%
if errorlevel 1 exit 1

REM Build step
cmake --build . --config Release
if errorlevel 1 exit 1

REM Test step
ctest --output-on-failure
if errorlevel 1 exit 1

REM Install step
cmake --build . --config Release --target install
if errorlevel 1 exit 1
