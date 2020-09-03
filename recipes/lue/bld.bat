@echo on

rem We need to create an out of source build
mkdir build

if errorlevel 1 exit 1

cd build

if errorlevel 1 exit 1


rem Some projects use this to ensure correct version is picked up
set "CC=cl.exe"
set "CXX=cl.exe"
rem

rem Ensure desired Boost version is selected by CMake
rem set "BOOST_ROOT=%PREFIX%"
rem set "BOOST_NO_SYSTEM_PATHS=ON"


cmake %SRC_DIR% -G"Ninja" ^
-D CMAKE_BUILD_TYPE=Release ^
-D CMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
-D CMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
-D LUE_DATA_MODEL_WITH_PYTHON_API=ON ^
-D LUE_DATA_MODEL_WITH_UTILITIES=ON ^
-D LUE_BUILD_VIEW=ON ^
-D Boost_USE_STATIC_LIBS=OFF ^
-D LUE_HAVE_BOOST=TRUE ^
-D LUE_HAVE_GDAL=TRUE ^
-D LUE_HAVE_HDF5=TRUE ^
-D HDF5_USE_STATIC_LIBRARIES=OFF ^
-D Python3_FIND_STRATEGY="LOCATION" ^
-D Python3_EXECUTABLE="%PYTHON%" ^
-D PYTHON_EXECUTABLE="%PYTHON%" ^
-D Python_ROOT_DIR="%PREFIX%/bin" ^
-D Python3_ROOT_DIR="%PREFIX%/bin"


if errorlevel 1 exit 1

cmake --build . --target all

if errorlevel 1 exit 1

cmake --build . --target install

if errorlevel 1 exit 1
