@ECHO ON

set "CC=gcc.exe"
set "CXX=g++.exe"
set "FC=gfortran.exe"

cmake %CMAKE_ARGS% ^
      -G "MinGW Makefiles" ^
      -S %SRC_DIR% ^
      -B build ^
      -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_C_FLAGS="%CFLAGS%" ^
      -D CMAKE_CXX_FLAGS="%CXXFLAGS%" ^
      -D CMAKE_Fortran_FLAGS="%FFLAGS%" ^
      -D CMAKE_INSTALL_LIBDIR="lib" ^
      -D CMAKE_INSTALL_INCLUDEDIR="include" ^
      -D CMAKE_INSTALL_BINDIR="bin" ^
      -D CMAKE_INSTALL_DATADIR="share" ^
      -D PYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
      -D PYTHON_EXECUTABLE="%PYTHON%" ^
      -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
      -D CMAKE_GNUtoMS=ON ^
      -D BUILD_TESTING=OFF ^
      -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -D ENABLE_OPENMP=OFF ^
      -D ENABLE_GENERIC=OFF ^
      -D ENABLE_TESTS=ON ^
      -D ENABLE_TIMER=OFF ^
      -D ENABLE_LOGGER=OFF ^
      -D BUILD_STANDALONE=ON ^
      -D ENABLE_CXX11_SUPPORT=ON
if errorlevel 1 exit 1

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

del %LIBRARY_PREFIX%\\share\\cmake\\PCMSolver\\PCMSolverTargets-static-release.cmake
del %LIBRARY_PREFIX%\\share\\cmake\\PCMSolver\\PCMSolverTargets-static.cmake
del %LIBRARY_PREFIX%\\lib\\libpcm.a

cd build
ctest -E "from-file" --rerun-failed --output-on-failure
if errorlevel 1 exit 1

