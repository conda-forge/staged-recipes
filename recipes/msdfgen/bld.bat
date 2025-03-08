@echo on
setlocal enabledelayedexpansion

if not exist build mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -DMSDFGEN_BUILD_STANDALONE=ON ^
    -DMSDFGEN_USE_SKIA=OFF ^
    -DMSDFGEN_DYNAMIC_RUNTIME=ON ^
    -DBUILD_SHARED_LIBS=ON ^
    -DMSDFGEN_USE_VCPKG=OFF ^
    -DMSDFGEN_INSTALL=ON ^
    ..

ninja -j%CPU_COUNT% -v
ninja install

