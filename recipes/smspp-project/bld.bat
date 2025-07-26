:: build SMS++

mkdir build
cd build
cmake %CMAKE_ARGS% ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
