@echo on
setlocal EnableDelayedExpansion

mkdir build || exit 1
cd build || exit 1


cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      .. || exit 1

cmake  --build . -j %CPU_COUNT% || exit 1
cmake --build . --target install || exit 1
