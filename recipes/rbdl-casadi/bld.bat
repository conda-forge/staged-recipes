mkdir build
cd build

cmake ../ ^
    -GNinja ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DRBDL_BUILD_STATIC=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DMATH_LIBRARY_BACKEND="Casadi"

cmake --build ./ ^
    --config Release ^
    --target install
