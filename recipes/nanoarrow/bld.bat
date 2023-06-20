mkdir build
chdir build

cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR% -D DBUILD_SHARED_LIBS=ON -D CMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1