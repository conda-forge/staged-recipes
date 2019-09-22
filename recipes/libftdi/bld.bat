mkdir build
cd build
echo ============
echo Listing prefix library dir
echo ============
dir %PREFIX%\Library\ /s /b sortorder:N
echo ============
REM Configure step
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%PREFIX%\Library" -DCMAKE_PREFIX_PATH="%PREFIX%\Library" "%SRC_DIR%"
if errorlevel 1 exit 1
REM Build step
cmake --build .
if errorlevel 1 exit 1
REM Install step
cmake --build . --target install
if errorlevel 1 exit 1
