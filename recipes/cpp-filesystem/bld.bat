cmake -G "NMake Makefiles" -D BUILD_TESTS=OFF -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR% ^
    -DGHC_FILESYSTEM_BUILD_TESTING=OFF -DGHC_FILESYSTEM_BUILD_EXAMPLES=OFF
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
