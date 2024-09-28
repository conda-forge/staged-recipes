@echo on

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% ..
cmake --build . --config Release --parallel %NUMBER_OF_PROCESSORS%
cmake --install . --config Release
