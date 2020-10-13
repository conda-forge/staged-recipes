mkdir build && cd build

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DDART_MSVC_DEFAULT_OPTIONS=ON ^
    -DDART_VERBOSE=ON ^
    %SRC_DIR%

echo "Print CMakeOutput:"
type CMakeFiles\CMakeOutput.log
echo "Print CMakeOutput:"
type CMakeFiles\CMakeError.log
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
