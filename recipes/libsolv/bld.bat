set "CFLAGS= -MD"
set "CXXFLAGS= -MD"
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit

mkdir build 
cd build

cmake -G "MinGW Makefiles" ^
      -D BUILD_TESTS=OFF ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_SH="CMAKE_SH-NOTFOUND" ^
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      ..
      
if errorlevel 1 exit 1

make -j %CPU_COUNT%
if errorlevel 1 exit 1

make install
if errorlevel 1 exit 1
