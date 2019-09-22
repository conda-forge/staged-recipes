echo ============
echo Running bld.bat
echo ============
dir %PREFIX% /s /b 
echo ============
mkdir build
cd build
REM Configure step
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%PREFIX%\Library" -DCMAKE_PREFIX_PATH="%PREFIX%\Library" -DPC_LIBUSB_INCLUDEDIR="%PREFIX%\Library\include"  -DPC_LIBUSB_LIBDIR="%PREFIX%\Library\lib" "%SRC_DIR%"
if errorlevel 1 exit 1
REM Build step
cmake --build .
if errorlevel 1 exit 1
REM Install step
cmake --build . --target install
if errorlevel 1 exit 1
