mkdir build
cd build

cmake ../^
    -G"%Visual Studio 15 2017 Win64%"^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%"^
    -DRBDL_BUILD_STATIC=ON

cmake --build ./^
    --config Release^
    --target install
