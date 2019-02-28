mkdir libxc_build
if errorlevel 1 exit 1

cd libxc_build
if errorlevel 1 exit 1

cmake -G Ninja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DENABLE_XHOST=OFF ^
      -DCMAKE_C_FLAGS="/wd4101 /wd4996 %CFLAGS%" ^
      ..
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

ctest --output-on-failure
if errorlevel 1 exit 1
