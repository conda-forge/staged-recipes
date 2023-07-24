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

cmake %CMAKE_ARGS% -DCOMPILER=MANUAL -DOPENMP=TRUE -DCUDA=%BUILD_CUDA% -DMPI=%BUILD_MPI% %SRC_DIR%

if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1