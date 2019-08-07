mkdir build 
cd build

cmake .. ^
	  -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_VERBOSE_MAKEFILE=ON ^
      -D CMAKE_INSTALL_LIBDIR=lib ^
      -D BUILD_OCTOVIS_SUBPROJECT=OFF ^
      -D BUILD_DYNAMICETD3D_SUBPROJECT=OFF

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
