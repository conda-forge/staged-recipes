set -e
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX}
cmake --build . --verbose --config Release
cmake --install . --verbose
