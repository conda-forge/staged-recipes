mkdir build
mkdir build\corelib
mkdir build\wrapper

cd build\corelib
cmake ^
    -G "NMake Makefiles JOM" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D ANACONDA_BUILD=ON ^
    -D ANACONDA_BASE=%LIBRARY_PREFIX% ^
    -D BUILD_NCORES=%NUMBER_OF_PROCESSORS% ^
    -D Boost_NO_BOOST_CMAKE=ON ^
    -D PYTHON_EXECUTABLE="%PYTHON%" ^
    ..\..\corelib
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

cd ..\wrapper
cmake ^
    -G "NMake Makefiles JOM" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D ANACONDA_BUILD=ON ^
    -D ANACONDA_BASE=%LIBRARY_PREFIX% ^
    -D BUILD_NCORES=%NUMBER_OF_PROCESSORS% ^
    -D Boost_NO_BOOST_CMAKE=ON ^
    -D PYTHON_EXECUTABLE="%PYTHON%" ^
    ..\..\wrapper
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

rmdir /Q /S %LIBRARY_PREFIX%\pkgs\sire-*
