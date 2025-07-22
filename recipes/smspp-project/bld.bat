:: build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=OFF ^
    -DCMAKE_MSVC_RUNTIME_LIBRARY="MultiThreaded" ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
