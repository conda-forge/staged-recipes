:: conda-forge folds the Intel compiler runtime libs (libircmt.lib, ...) into the
:: build-only dpcpp_impl package (not visible from the host env), so they live
:: in the build prefix and are off the linker's default LIB
set "LIB=%BUILD_PREFIX%\Library\lib;%LIB%"

"%PYTHON%" setup.py clean --all

set "MKLROOT=%PREFIX%/Library"
set "TBB_ROOT_HINT=%PREFIX%/Library"
set "DPL_ROOT_HINT=%PREFIX%/Library"
:: useful for building in resources constrained VMs (public CI)
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=FALSE"

:: try to detect SYCL resource/include dir from icpx
for /f "usebackq delims=" %%R in (`icpx --print-resource-dir 2^>NUL`) do (
  set "SYCL_RESOURCE_DIR=%%R"
)

if defined SYCL_RESOURCE_DIR (
  if exist "%SYCL_RESOURCE_DIR%\include" (
    set "SYCL_INCLUDE_DIR_HINT=%SYCL_RESOURCE_DIR%"
  )
)

set "CC=icx"
set "CXX=icx"

set "CMAKE_GENERATOR=Ninja"
:: make CMake verbose
set "VERBOSE=1"

:: use all logical processors (CPU_COUNT caps at physical cores) to fit the CI time limit
set CMAKE_BUILD_PARALLEL_LEVEL=%NUMBER_OF_PROCESSORS%

:: flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x
if %errorlevel% neq 0 exit 1

:: wheel file was renamed
for /f %%f in ('dir /b /S .\dist') do (
  %PYTHON% -m pip install %%f ^
    --no-build-isolation ^
    --no-deps ^
    --only-binary :all: ^
    --no-index ^
    --prefix %PREFIX% ^
    -vv
    if errorlevel 1 exit 1
)
