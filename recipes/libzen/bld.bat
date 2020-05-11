rem Create Makefiles
cmake -g Ninja ^
      -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DINCLUDE_INSTALL_DIR=%PREFIX%\include ^
      -DLIB_INSTALL_DIR=%PREFIX%\lib ^
      -S Project\CMake ^
      -B build

rem Build
cmake  --build build -- -j${CPU_COUNT}

rem Install
cmake --build build -- install

rem Test / Check ?
rem There is no make check/test
