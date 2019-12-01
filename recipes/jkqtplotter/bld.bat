:: Fix for https://github.com/jkriege2/JKQtPlotter/issues/35
set "CXXFLAGS=%CXXFLAGS:-GL=%"

mkdir build
cd build
cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DJKQtPlotter_BUILD_EXAMPLES=OFF ^
    -DJKQtPlotter_BUILD_STATIC_LIBS=OFF ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..
if errorlevel 1 exit 1
ninja install -j%CPU_COUNT%
if errorlevel 1 exit 1
