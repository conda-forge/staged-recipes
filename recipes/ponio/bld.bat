cmake %CMAKE_ARGS% -G "Ninja" -D CMAKE_SYSTEM_PROCESSOR=x64 -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% %SRC_DIR% -B build
if errorlevel 1 exit 1

cmake --build build --target install
if errorlevel 1 exit 1
