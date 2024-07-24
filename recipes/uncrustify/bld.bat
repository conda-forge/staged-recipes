cmake -S . -G Ninja -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -Wno-dev \
    -DBUILD_TESTING=OFF \
    %CMAKE_ARGS%

cmake --build build -j%CPU_COUNT%
cmake --install build

mkdir %PREFIX%\share\doc\%PKG_NAME%
xcopy /s /e /t documentation\* %PREFIX%\share\doc\%PKG_NAME%
