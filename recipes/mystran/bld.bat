mkdir build
cd build

cmake -G "Ninja" ^
      -D BUID_WITH_CONDA:BOOL=ON ^
      -D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      ..

ninja install