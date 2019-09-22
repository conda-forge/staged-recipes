echo ============
echo Running bld.bat
echo ============
dir %PREFIX% /s /b 
echo ============
mkdir build
cd build
REM Configure step
cmake -G "%CMAKE_GENERATOR%" -DCMAKE_INSTALL_PREFIX="%PREFIX%\Library" -DCMAKE_PREFIX_PATH="%PREFIX%\Library" -DLIBUSB_INCLUDE_DIR="%PREFIX%\Library\include\libusb-1.0\"  -DLIBUSB_LIBRARIES="%PREFIX%\Library\lib\libusb-1.0_static.lib" "%SRC_DIR%"
if errorlevel 1 exit 1
REM Build step
cmake --build .
if errorlevel 1 exit 1
REM Install step
cmake --build . --target install
if errorlevel 1 exit 1
