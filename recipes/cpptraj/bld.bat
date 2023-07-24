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
  -D CMAKE_PREFIX_PATH="%PREFIX%" ^
  -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -D PYTHON_EXECUTABLE=%PYTHON% ^
  -D COMPILER=AUTO ^
  -D OPENMP=FALSE ^
  -D CUDA=%BUILD_CUDA% ^
  -D MPI=%BUILD_MPI%

if errorlevel 1 exit 1

cmake --build build ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1
