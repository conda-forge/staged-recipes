@echo on

set OPENSSL_ROOT_DIR=%PREFIX%

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% ..
cmake --build . --config Release --parallel %CPU_COUNT%
cmake --install .
