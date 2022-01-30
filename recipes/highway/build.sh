set -ex
ls -lah
mkdir c_build
cd c_build

# glibc 2.12 (Current default at conda-forge)
# doesn't define certain string macros without
# this definition.
# it has been removed in glibc 2.17
# https://github.com/google/highway/pull/524#issuecomment-1025676250
CXXFLAGS="-D__STDC_FORMAT_MACROS ${CXXFLAGS}"
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

