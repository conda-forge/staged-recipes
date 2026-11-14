setlocal EnableDelayedExpansion
@echo on

mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_LIBDIR:STRING=lib ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DIONOS_BUILD_TESTS=OFF ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
