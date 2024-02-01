mkdir build
pushd build

cmake -G Ninja --install-prefix %LIBRARY_PREFIX% %SRC_DIR%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1
