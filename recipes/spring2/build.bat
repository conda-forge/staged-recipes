@echo off
setlocal enabledelayedexpansion

REM conda-build invokes bld.bat a second time during the packaging phase in a
REM fresh cmd session, so VSCMD_VER (set only by a successful vcvarsall call)
REM cannot serve as a cross-session sentinel. Use a file flag to detect that
REM the first build and install already completed successfully and exit early.
set "BUILD_DONE_SENTINEL=%SRC_DIR%\build-conda\.spring2_build_done"
if exist "%BUILD_DONE_SENTINEL%" (
  echo bld.bat: spring2 already built and installed ^(sentinel exists^). Skipping.
  exit /b 0
)

where ninja >nul 2>nul
if errorlevel 1 (
  echo ERROR: ninja not found on PATH after environment setup
  exit /b 1
)

cmake -S . -B build-conda -G Ninja ^
%CMAKE_ARGS% ^
-DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
-DCMAKE_INSTALL_BINDIR=Library\bin ^
-DCMAKE_INSTALL_LIBDIR=Library\lib ^
-DSPRING_ENABLE_COMPILER_CACHE=OFF
if errorlevel 1 exit /b 1

cmake --build build-conda --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1

cmake --install build-conda
if errorlevel 1 exit /b 1

echo done > "%BUILD_DONE_SENTINEL%"
