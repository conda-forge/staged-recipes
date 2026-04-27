@echo on

cmake -S . -B build -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DBLEND2D_STATIC=OFF ^
    -DBLEND2D_TEST=OFF ^
    -DBLEND2D_EXTERNAL_ASMJIT=ON ^
    -DBLEND2D_NO_STDCXX=OFF
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
