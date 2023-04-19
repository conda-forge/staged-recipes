@echo on

mkdir build
if errorlevel 1 exit 1

cd build

cmake %CMAKE_ARGS% -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB% ^
      -DCMAKE_INSTALL_INCLUDEDIR=%LIBRARY_INC% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON ^
      -DBUILD_SHARED_LIBS=ON ^
      ..
if errorlevel 1 exit 1

cmake --build . --config Release --target igraph -j%CPU_COUNT%
if errorlevel 1 exit 1

cmake --build . --config Release --target install -j%CPU_COUNT%
if errorlevel 1 exit 1
