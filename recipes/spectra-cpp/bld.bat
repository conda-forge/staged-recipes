REM NOTE: Skipping tests on windows, library itself doesnt test windows

cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR% -D BUILD_SHARED_LIBS=ON -D CMAKE_BUILD_TYPE=Release
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1