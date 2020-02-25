@echo on

rem We need to create an out of source build
mkdir build
cd build


rem Some projects use this to ensure correct version is picked up
set "CC=cl.exe"
set "CXX=cl.exe"
rem


set "BOOST_ROOT=%PREFIX%"
set "BOOST_NO_SYSTEM_PATHS=ON"


cmake .. -G"Ninja" ^
-D CMAKE_BUILD_TYPE=Release  ^
-D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%;%CMAKE_PREFIX_PATH%" ^
-D CMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%"  ^
-D Python3_ROOT_DIR:PATH=%LIBRARY_PREFIX% ^
-D Python3_EXECUTABLE="%PYTHON%" ^
-D PYTHON_EXECUTABLE="%PYTHON%" ^
-D Python3_ROOT_DIR="%PREFIX%" ^
-D PCRASTER_BUILD_TEST=OFF ^
-D PCRASTER_PYTHON_INSTALL_DIR="%SP_DIR%" ^
-D CMAKE_TOOLCHAIN_FILE=..\environment\cmake\msvs2017.cmake

if errorlevel 1 exit 1

cmake --build . --target all

if errorlevel 1 exit 1

cmake --build . --target install

if errorlevel 1 exit 1
