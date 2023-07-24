@echo on

mkdir build
cd build

set BUILD_MPI=FALSE

if "%mpi%" NEQ "nompi" (
    set BUILD_MPI=TRUE
)

set BUILD_CUDA=FALSE

if not "%cuda_compiler_version%"=="None" (
    set BUILD_CUDA=TRUE
)

cmake %CMAKE_ARGS% ^
  -G "Ninja" ^
  -S %SRC_DIR% ^
  -B build ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX="%PREFIX%" ^
  -D CMAKE_C_COMPILER=clang-cl ^
  -D CMAKE_C_FLAGS="%CFLAGS%" ^
  -D CMAKE_CXX_COMPILER=clang-cl ^
  -D CMAKE_CXX_FLAGS="%CXXFLAGS%" ^
  -D CMAKE_Fortran_COMPILER=flang ^
  -D CMAKE_INSTALL_LIBDIR="Library\lib" ^
  -D CMAKE_INSTALL_INCLUDEDIR="Library\include" ^
  -D CMAKE_INSTALL_BINDIR="Library\bin" ^
  -D CMAKE_INSTALL_DATADIR="Library\share" ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D BUILD_SHARED_LIBS=ON ^
  -D Python_EXECUTABLE="%BUILD_PREFIX%\python.exe" ^
  -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
  -D COMPILER=MANUAL ^
  -D OPENMP=FALSE ^
  -D CUDA=%BUILD_CUDA% ^
  -D MPI=%BUILD_MPI%

if errorlevel 1 exit 1

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1
