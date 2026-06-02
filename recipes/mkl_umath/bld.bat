REM A workaround for activate-dpcpp.bat issue
set "LIB=%BUILD_PREFIX%\Library\lib;%BUILD_PREFIX%\compiler\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\include;%INCLUDE%"

FOR %%V IN (14.0.0 14 15.0.0 15 16.0.0 16 17.0.0 17) DO @(
  IF EXIST "%BUILD_PREFIX%\Library\lib\clang\%%V\" (
    SET "SYCL_INCLUDE_DIR_HINT=%BUILD_PREFIX%\Library\lib\clang\%%V"
  )
)

set "CMAKE_GENERATOR=Ninja"
set "CMAKE_ARGS=-DCMAKE_C_COMPILER:PATH=icx -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON"

"%PYTHON%" -m pip install --no-build-isolation --no-deps .
if errorlevel 1 exit 1
