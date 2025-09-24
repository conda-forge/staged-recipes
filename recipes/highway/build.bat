mkdir build-hwy
cd build-hwy

cmake %CMAKE_ARGS% -GNinja .. ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_TESTING=OFF ^
      -DBUILD_SHARED_LIBS=ON

ninja install
