mkdir build
cd build

set CONFIGURATION=Release

cmake .. ^
	%{CMAKE_ARGS}% ^
	-G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
	-DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
	-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	-DPython_EXECUTABLE="%PYTHON%" ^
	-DCMAKE_CXX_FLAGS="-DBOOST_ALL_NO_LIB /EHsc" ^
	-DWITH_OPENMP=ON

if errorlevel 1 exit 1

nmake all
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
