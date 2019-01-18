mkdir build
cd build

cmake -G "NMake Makefiles" ^
	  -DUSE_FFMPEG=ON ^
	  -DOIIO_BUILD_TOOLS=OFF ^
	  -DOIIO_BUILD_TESTS=OFF ^
	  -DUSE_PYTHON=OFF ^
	  -DUSE_OPENCV=OFF ^
	  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
	  -DCMAKE_INSTALL_LIBDIR=lib ^
	  %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
