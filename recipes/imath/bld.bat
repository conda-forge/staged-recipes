mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_FIND_ROOT_PATH="%LIBRARY_PREFIX%" ^
      -DBUILD_SHARED_LIBS=ON ^
      -DIMATH_LIB_SUFFIX="" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -G "NMake Makefiles" ..

nmake
nmake install