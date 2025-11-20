REM A workaround for activate-dpcpp.bat issue to be addressed in 2021.4
set "LIB=%BUILD_PREFIX%\Library\lib;%BUILD_PREFIX%\compiler\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\include;%INCLUDE%"

"%PYTHON%" setup.py clean --all

REM useful for building in resources constrained VMs (public CI)
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=FALSE"

REM Try to detect SYCL resource/include dir from icpx
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
:: Make CMake verbose
set "VERBOSE=1"

:: set CMAKE to use less threads to avoid OOM
set CMAKE_BUILD_PARALLEL_LEVEL=%CPU_COUNT%

set "CMAKE_ARGS=%CMAKE_ARGS% -DDPCTL_LEVEL_ZERO_INCLUDE_DIR=%PREFIX:\=/%/Library/include/level_zero"

%PYTHON% -m build -w -n -x
if %ERRORLEVEL% neq 0 exit 1

:: wheel file was renamed
for /f %%f in ('dir /b /S .\dist') do (
    %PYTHON% -m pip install %%f ^
      --no-build-isolation ^
      --no-deps ^
      --only-binary :all: ^
      --no-index ^
      --prefix %PREFIX% ^
      -vv
    if %ERRORLEVEL% neq 0 exit 1
)
