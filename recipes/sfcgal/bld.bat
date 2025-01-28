cmake -S . -B build ^
         -G Ninja ^
         -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE ^
         -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
         -DCMAKE_BUILD_TYPE=Release ^
         -DSFCGAL_BUILD_TESTS=OFF ^
         -Wno-dev
cmake --build build --config Release
cmake --install build

