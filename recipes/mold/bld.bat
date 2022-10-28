@echo on

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp
cmake .. ^
      -G "Visual Studio 16 2019" ^
      -T clangcl ^
      -DCMAKE_PREFIX_PATH=%PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DMOLD_USE_SYSTEM_TBB=ON ^
      -DMOLD_USE_SYSTEM_MIMALLOC=ON ^
      -DCMAKE_BUILD_TYPE=Release 

cmake --build . --config Release --target install
if errorlevel 1 exit 1