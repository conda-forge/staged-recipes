mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

:: Env variable for MKL linking (from mkl linker advisor)
SET MKL="mkl_intel_lp64_dll.lib mkl_sequential_dll.lib mkl_core_dll.lib"

cmake .. ^
        -G "%CMAKE_GENERATOR%" ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
        -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
        -DBUILD_STATIC_LIBS=1 ^
        -DBUILD_SHARED_LIBS=1 ^
        -DALPS_ENABLE_MPI=OFF ^
        -DALPS_BUILD_APPLICATIONS=ON ^
        -DALPS_BUILD_EXAMPLES=OFF ^
        -DBOOST_ROOT="%PREFIX%" ^
        -DBoost_NO_SYSTEM_PATHS=ON ^
        -DBOOST_INCLUDEDIR="%LIBRARY_INC%" ^
        -DBOOST_LIBRARYDIR="%LIBRARY_BIN%" ^
        -DPYTHON_EXECUTABLE="%PYTHON%"
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

ctest --output-on-failure
if errorlevel 1 exit 1

:: Move pyalps to site packages
move %LIBRARY_LIB%\pyalps "%SP_DIR%"
