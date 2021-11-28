set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -DBUILD_STATIC_LIBS=OFF ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_TESTS=ON ^
    -DBUILD_LIBPRIMESIEVE=OFF ^
    .

ninja install -j%CPU_COUNT%

ctest -j%CPU_COUNT% --output-on-failure
