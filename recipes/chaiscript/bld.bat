cmake -G "NMake Makefiles" -D BUILD_MODULES=OFF -D BUILD_TESTING=OFF -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1