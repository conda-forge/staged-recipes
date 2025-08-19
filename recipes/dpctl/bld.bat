REM A workaround for activate-dpcpp.bat issue to be addressed in 2021.4
set "LIB=%BUILD_PREFIX%\Library\lib;%BUILD_PREFIX%\compiler\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\include;%INCLUDE%"

"%PYTHON%" setup.py clean --all

REM useful for building in resources constrained VMs (public CI)
set "CMAKE_ARGS=%CMAKE_ARGS% -DCMAKE_INTERPROCEDURAL_OPTIMIZATION:BOOL=FALSE"

FOR %%V IN (17.0.0 17 18.0.0 18 19.0.0 19 20.0.0 20 21.0.0 21) DO @(
  REM set DIR_HINT if directory exists
  IF EXIST "%BUILD_PREFIX%\Library\lib\clang\%%V\" (
     SET "SYCL_INCLUDE_DIR_HINT=%BUILD_PREFIX%\Library\lib\clang\%%V"
  )
)

set "PATCHED_CMAKE_VERSION=3.26"
set "PLATFORM_DIR=%PREFIX%\Library\share\cmake-%PATCHED_CMAKE_VERSION%\Modules\Platform"
set "FN=Windows-IntelLLVM.cmake"

rem Save the original file, and copy patched file to
rem fix the issue with IntelLLVM integration with cmake on Windows
if EXIST "%PLATFORM_DIR%" (
  dir "%PLATFORM_DIR%\%FN%"
  copy /Y "%PLATFORM_DIR%\%FN%" .
  if %ERRORLEVEL% neq 0 exit 1
  copy /Y ".github\workflows\Windows-IntelLLVM_%PATCHED_CMAKE_VERSION%.cmake" "%PLATFORM_DIR%\%FN%"
  if %ERRORLEVEL% neq 0 exit 1
)

set "CC=icx"
set "CXX=icx"

set "CMAKE_GENERATOR=Ninja"
:: Make CMake verbose
set "VERBOSE=1"

:: set CMAKE to use less threads to avoid OOM
set CMAKE_BUILD_PARALLEL_LEVEL=2

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
