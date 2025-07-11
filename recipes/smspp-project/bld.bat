:: build SMS++
git submodule init
git submodule update

mkdir build
cd build
cmake %CMAKE_ARGS% -DCMAKE_CONFIGURATION_TYPES="Release" ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
