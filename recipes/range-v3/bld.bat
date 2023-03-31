mkdir build
cd build

cmake ^
    -G "Visual Studio 16 2019" -A x64 ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DBUILD_TESTING=YES ^
    -DRANGES_ASSERTIONS=NO ^
    -DRANGES_BUILD_CALENDAR_EXAMPLE=NO ^
    -DRANGES_DEBUG_INFO=NO ^
    -DRANGE_V3_DOCS=NO ^
    -DRANGE_V3_EXAMPLES=NO ^
    -DRANGE_V3_TESTS=YES ^
    ..

cmake --build . --config Release

ctest --output-on-failure -j${CPU_COUNT} -V -C Release

cmake --build . --config Release --target install
