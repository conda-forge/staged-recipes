
set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"
set "MINGWBIN=%LIBRARY_PREFIX%/mingw-w64/bin"

set BUILD_TYPE=Release

set "LDFLAGS=%LDFLAGS% -lnetcdff"

mkdir build 
cd build

cmake -LAH -G "Unix Makefiles" ^
  %CMAKE_ARGS% ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
  -D GRIB=OFF ^
  -D NCDF=ON ^
  -D OPENGL=OFF ^
  %SRC_DIR%
if errorlevel 1 exit 1

:: cmake --build . --target install --config %BUILD_TYPE%
make
make install
if errorlevel 1 exit 1
