
cd build-cmake
mkdir build
cd build

cmake -G "Ninja" ^
      %CMAKE_ARGS% ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DBUILD_PROTOC=OFF ^
      -DBUILD_SHARED_LIBS=ON ^
      ..

ninja -j %CPU_COUNT%

ninja install
