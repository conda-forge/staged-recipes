mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

set BUILDCONF=Release

set "CMAKE_COMPILER_PATH=%VSINSTALLDIR:\=/%/VC/bin/amd64"

cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE:STRING=%CMAKE_CONFIG% ^
      -D BUILD_SHARED_LIBS:BOOL=ON ^
      -D BUILD_STATIC_LIBS:BOOL=ON ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      "%SRC_DIR%"
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
