:: build SMS++
git submodule init
git submodule update

set "CFLAGS=%CFLAGS% /I%LIBRARY_PREFIX%\include"
set "CXXFLAGS=%CXXFLAGS% /I%LIBRARY_PREFIX%\include"
set "LDFLAGS=%LDFLAGS% /L%LIBRARY_PREFIX%\lib"

mkdir build
cd build
cmake %CMAKE_ARGS% ^
    -DBUILD_SHARED_LIBS=OFF ^
    ..
cmake --build . --config Release -j%CPU_COUNT%
cmake --install . --config Release --prefix "$PREFIX"
