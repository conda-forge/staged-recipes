set -ex
ls -lah
mkdir c_build
cd c_build
cmake                                \
    ${CMAKE_ARGS}                    \
    -DCMAKE_BUILD_TYPE=Release       \
    -DBUILD_TESTING=OFF              \
    -DBUILD_SHARED_LIBS=ON           \
    -DHWY_ENABLE_INSTALL=ON          \
    -DHWY_ENABLE_EXAMPLES=OFF        \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

cmake --build .
cmake --install .

