cmake -S . -B build ^
         -G Ninja ^
         -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DSFCGAL_BUILD_TESTS=OFF ^
         -Wno-dev
cmake --build build --config Release
cmake --install build

