@echo on

rem We need to create an out of source build
mkdir build
cd build

rem Some projects use this to ensure correct version is picked up
set "CC=cl.exe"
set "CXX=cl.exe"
rem


set "PCR_INST=%PREFIX%"

set "BOOST_ROOT=%PREFIX%"
set "BOOST_NO_SYSTEM_PATHS=ON"



cmake .. -G"Ninja" ^
-D CMAKE_BUILD_TYPE=Release  ^
-D CMAKE_PREFIX_PATH="%PREFIX%\Library;%CMAKE_PREFIX_PATH%" ^
-D CMAKE_INSTALL_PREFIX:PATH="%PCR_INST%"  ^
-D Python3_ROOT_DIR:PATH=%LIBRARY_PREFIX% ^
-D Python3_EXECUTABLE="%PYTHON%" ^
-D PYTHON_EXECUTABLE="%PYTHON%" ^
-D Python3_ROOT_DIR="%PREFIX%" ^
-D PCRASTER_BUILD_TEST=OFF ^
-D PCRASTER_PACKAGE_QT_PLATFORMS=ON ^
-D CMAKE_TOOLCHAIN_FILE=..\environment\cmake\msvs2017.cmake


cmake --build . --target install

if errorlevel 1 exit 1

rem hack
%PYTHON% %RECIPE_DIR%\postinstall.py %PCR_INST% %PCR_INST%

rem hack even more
del %PCR_INST%\bin\platforms\qdirect2d.dll
del %PCR_INST%\bin\platforms\qminimal.dll
del %PCR_INST%\bin\platforms\qoffscreen.dll
del %PCR_INST%\bin\platforms\qwebgl.dll
