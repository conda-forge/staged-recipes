@echo on

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp
cmake .. ^
      -GNinja ^
      -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 ^
      -DMOLD_MOSTLY_STATIC=ON ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_BUILD_TYPE=Release 

cmake --build . --config Release --target install
if errorlevel 1 exit 1