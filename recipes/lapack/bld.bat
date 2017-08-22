mkdir build
cd build

REM Trick to avoid CMake/sh.exe error
ren "C:\Program Files\Git\usr\bin\sh.exe" _sh.exe

cmake -G "MinGW Makefiles" -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release -DLAPACKE=ON -DCBLAS=ON -Wno-dev ..
%LIBRARY_PREFIX%\mingw-w64\bin\mingw32-make
%LIBRARY_PREFIX%\mingw-w64\bin\mingw32-make install

ctest --output-on-failure
