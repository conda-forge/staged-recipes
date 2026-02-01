@echo off
echo DEBUG: PREFIX is %PREFIX%
echo DEBUG: LIBRARY_PREFIX is %LIBRARY_PREFIX%
echo DEBUG: SRC_DIR is %SRC_DIR%
echo DEBUG: BUILD_PREFIX is %BUILD_PREFIX%  REM optional, sometimes set

if "%LIBRARY_PREFIX%"=="" (
    echo ERROR: LIBRARY_PREFIX is empty! Exiting.
    exit /b 1
)

cmake -G"NMake Makefiles" ^
  -B build
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  .
if errorlevel 1 exit 1

cmake --build build
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
