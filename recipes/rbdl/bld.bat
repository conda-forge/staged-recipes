mkdir build
cd build

cmake ../^
    -G"%Visual Studio 14 2015 Win64%"^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%"^
    -DRBDL_BUILD_STATIC=ON

cmake --build ./^
    --config Release^
    --target install
