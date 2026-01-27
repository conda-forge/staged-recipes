@echo on

@REM Use `lib` instead of `lib64` for tests
sed -i "s#include(GNUInstallDirs)#&\nset(CMAKE_INSTALL_LIBDIR lib CACHE STRING "" FORCE)#" cmake/Corrosion.cmake

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DCORROSION_BUILD_TESTS=ON
cmake --build build --parallel %CPU_COUNT%

ctest -V --test-dir build --parallel %CPU_COUNT%
cmake --install build
