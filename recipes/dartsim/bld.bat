mkdir build && cd build

# Build with Clang toolset
set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

cmake -G "NMake Makefiles" ^
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

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
