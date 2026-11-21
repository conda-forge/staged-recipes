cmake -S . -B build -G Ninja %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -DOJPH_BUILD_EXECUTABLES=OFF ^
    -DOJPH_ENABLE_TIFF_SUPPORT=OFF ^
    -DOJPH_REQUIRE_HWY=ON
if errorlevel 1 exit 1
cmake --build build
if errorlevel 1 exit 1
cmake --install build
if errorlevel 1 exit 1
