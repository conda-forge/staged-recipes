
mkdir build
cd build

REM Make shared libs
cmake -G"Ninja" ^
      %CMAKE_ARGS% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DCMAKE_FIND_FRAMEWORK=NEVER ^
      -DCMAKE_FIND_APPBUNDLE=NEVER ^
      -DBUILD_SHARED_LIBS=ON ^
      -DBUILD_d=ON ^
      -DBUILD_4=ON ^
      -DBUILD_8=ON ^
      %SRC_DIR%
if errorlevel 1 exit 1

REM Build step
cmake --build . --config Release
if errorlevel 1 exit 1

REM Install step
cmake --build . --config Release --target install
if errorlevel 1 exit 1
