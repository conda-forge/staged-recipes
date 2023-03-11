
mkdir build
cd build

# Make shared libs
cmake -G %CMAKE_GENERATOR% ^
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
nmake
nmake install
