dir "%LIBRARY_BIN%"

:: Compile clapack
%PYTHON% %RECIPE_DIR%\get_clapack_src.py
if errorlevel 1 exit 1

mkdir build_clapack
if errorlevel 1 exit 1
cd build_clapack
if errorlevel 1 exit 1

cmake ^
    -G "%CMAKE_GENERATOR%" ^
    -DCMAKE_INSTALL_PREFIX="%SRC_DIR%\ext" ^
    -DBoost_ROOT_DIR="%LIBRARY_INC%" ^
    ../clapack
if errorlevel 1 exit 1

cmake --build . --config Release -- /consoleloggerparameters:ErrorsOnly;Summary /verbosity:minimal
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1



:: Start actual ALPS build
cd %SRC_DIR%
if errorlevel 1 exit 1


mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib


cmake ^
      -Wno-dev ^
      -G "%CMAKE_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DBUILD_STATIC_LIBS=1 ^
      -DBUILD_SHARED_LIBS=1 ^
      -DALPS_ENABLE_MPI=OFF ^
      -DALPS_BUILD_TESTS=OFF ^
      -DALPS_BUILD_APPLICATIONS=ON ^
      -DALPS_BUILD_EXAMPLES=OFF ^
      -DBOOST_ROOT="%PREFIX%" ^
      -DBoost_NO_SYSTEM_PATHS=ON ^
      -DBOOST_INCLUDEDIR="%LIBRARY_INC%" ^
      -DBOOST_LIBRARYDIR="%LIBRARY_LIB%" ^
      -DLAPACK_FOUND=TRUE ^
      -DBLAS_LIBRARY="%SRC_DIR%\ext\lib\blas.lib" ^
      -DLAPACK_LIBRARY="%SRC_DIR%\ext\lib\lapack.lib" ^
      -DPYTHON_EXECUTABLE="%PYTHON%" ^
      -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%/include" ^
      -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
      -DPYTHON_NUMPY_INCLUDE_DIR:PATH="%SP_DIR%/numpy/core/include" ^
      -DALPS_HAS_CMAKE_PI_MACROS=OFF ^
      ..
if errorlevel 1 exit 1

type CMakeCache.txt

cmake --build . --config Release -- /consoleloggerparameters:Summary /verbosity:minimal
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

ctest --output-on-failure
if errorlevel 1 exit 1

:: Move pyalps to site packages
move %LIBRARY_LIB%\pyalps "%SP_DIR%"
