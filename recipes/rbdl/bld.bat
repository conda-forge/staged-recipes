mkdir build
cd build

cmake ../^
    -G"%CMAKE_GENERATOR%"^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%"^
    -DRBDL_BUILD_STATIC=ON

cmake --build ./^
    --config Release^
    --target install
