cmake -G "NMake Makefiles" -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR% -B build
if errorlevel 1 exit 1

cmake --build build -t install
if errorlevel 1 exit 1
