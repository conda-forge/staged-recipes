setlocal EnableDelayedExpansion

:: Copy CMake files to the source directory
xcopy /E %RECIPE_DIR%\cmake %SRC_DIR%

cd %SRC_DIR%
mkdir build
cd build

:: Configure using the CMakeFiles
cmake -G "NMake Makefiles" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DIPOPT_BUILD_EXAMPLES=1 ^
      -DIPOPT_HAS_BLAS=1 ^
      -DIPOPT_HAS_LAPACK=1 ^
      -DIPOPT_HAS_MUMPS=1 ^
      -DIPOPT_HAS_RAND=1 ^
      -DIPOPT_ENABLE_LINEARSOLVERLOADER=1 ^
      -DCOIN_LINK_GFORTRAN=FALSE ^
      -DCOIN_USE_SYSTEM_LAPACK=TRUE ^
      -DCOIN_HAS_MUMPS_INCLUDE_PATH="%LIBRARY_INC%\mumps_seq" ^
      -DCOIN_HAS_MUMPS_LIBRARY_PATH="%LIBRARY_BIN%" ^
      ..
if errorlevel 1 exit 1
cmake --build . --config Release --target install
if errorlevel 1 exit 1
