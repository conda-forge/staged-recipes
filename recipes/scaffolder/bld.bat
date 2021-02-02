rem Create Makefiles
cmake -g Ninja ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_CXX_STANDARD=11 \ ^
      -S . -B build

rem Build
cmake  --build build -- -j${CPU_COUNT}

rem Install
cmake --install build --component scaffolder

rem Test / Check ?
rem There is no make check/test