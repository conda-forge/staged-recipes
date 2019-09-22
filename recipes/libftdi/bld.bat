echo ============
echo Running bld.bat
echo ============
dir %PREFIX% /s /b sortorder:N
echo ============
mkdir build
cd build
REM Configure step
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%PREFIX%" -DCMAKE_PREFIX_PATH="%PREFIX%" "%SRC_DIR%"
if errorlevel 1 exit 1
REM Build step
cmake --build .
if errorlevel 1 exit 1
REM Install step
cmake --build . --target install
if errorlevel 1 exit 1
