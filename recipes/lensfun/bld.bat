set CMAKE_CONFIG="Release"
if errorlevel 1 exit 1

mkdir build_%CMAKE_CONFIG%
if errorlevel 1 exit 1

pushd build_%CMAKE_CONFIG%
if error level 1 exit 1

cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE:STRING=%CMAKE_CONFIG% ^
      -D BUILD_SHARED_LIBS:BOOL=ON ^
      -D BUILD_STATIC_LIBS:BOOL=ON ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      "%SRC_DIR%"
if errorlevel 1 exit 1

cmake --build . --target install --config %CMAKE_CONFIG%
if errorlevel 1 exit 1
