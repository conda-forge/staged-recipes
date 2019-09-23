echo ============
echo Running bld.bat
echo ============
dir %PREFIX% /s /b 
echo ============
echo Running cmake...
mkdir build
cd build
echo cmake -G "%CMAKE_GENERATOR%" 
echo  -DCMAKE_INSTALL_PREFIX="%PREFIX%"\Library ^
echo  -DCMAKE_PREFIX_PATH="%PREFIX%"\Library ^
echo  -DLIBUSB_INCLUDE_DIR="%PREFIX%"\Library\include\libusb-1.0 ^
echo  -DLIBUSB_LIBRARIES="%PREFIX%"\Library\lib\libusb-1.0_static.lib ^
echo  "%SRC_DIR%"
REM Configure step
cmake -G "%CMAKE_GENERATOR%" ^
  -DCMAKE_INSTALL_PREFIX="%PREFIX%"\Library ^
  -DCMAKE_PREFIX_PATH="%PREFIX%"\Library ^
  -DLIBUSB_INCLUDE_DIR="%PREFIX%"\Library\include\libusb-1.0 ^
  -DLIBUSB_LIBRARIES="%PREFIX%"\Library\lib\libusb-1.0_static.lib ^
  "%SRC_DIR%"
if errorlevel 1 exit 1
REM Build step
cmake --build .
if errorlevel 1 exit 1
REM Install step
cmake --build . --target install
if errorlevel 1 exit 1
