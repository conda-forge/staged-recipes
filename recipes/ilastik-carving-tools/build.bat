mkdir build
cd build

set CONFIGURATION=Release

cmake .. ^
	%CMAKE_ARGS% ^
	-G "Ninja" ^
    -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
	-DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
	-DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	-DPython_EXECUTABLE="%PYTHON%" ^
	-DCMAKE_CXX_FLAGS="-DBOOST_ALL_NO_LIB /EHsc" ^
	-DWITH_OPENMP=ON

if errorlevel 1 exit 1

cmake --build . --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
