@echo on

mkdir build
cd build

cmake %CMAKE_ARGS% -G Ninja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DBUILD_TESTING=OFF ^
      -DBUILD_EXAMPLES=OFF ^
      ..
if errorlevel 1 exit 1

cmake --build . --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
