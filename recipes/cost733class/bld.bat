
set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"
::set "MINGWBIN=%LIBRARY_PREFIX%/mingw-w64/bin"

::  -D CMAKE_C_COMPILER:PATH=%MINGWBIN%/gcc.exe ^
::  -D CMAKE_Fortran_COMPILER:PATH=%MINGWBIN%/gfortran.exe ^
::  -D CMAKE_GNUtoMS:BOOL=ON ^

set BUILD_TYPE=Release

set "LDFLAGS=-L%LIBRARY_PREFIX%/lib -Wl,-rpath,%LIBRARY_PREFIX%/lib -lnetcdff"
set "CFLAGS=-fPIC -I%LIBRARY_PREFIX%/include"

mkdir build 
cd build

cmake -LAH -G "MinGW Makefiles" ^
  %CMAKE_ARGS% ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
  -D GRIB=OFF ^
  -D NCDF=ON ^
  -D OPENGL=OFF ^
  %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --target install --config %BUILD_TYPE%
if errorlevel 1 exit 1
