@echo off
setlocal EnableDelayedExpansion

:: Resolve the compiler activated by gfortran_win-64, not a runner's MSYS2 install.
if not defined FC (
    echo ERROR: gfortran_win-64 did not activate a Fortran compiler.
    exit /b 1
)
set "MINGW_GFORTRAN="
for /f "delims=" %%F in ('where "%FC%"') do (
    if not defined MINGW_GFORTRAN set "MINGW_GFORTRAN=%%F"
)
if not defined MINGW_GFORTRAN (
    echo ERROR: Fortran compiler %FC% was not found on PATH.
    exit /b 1
)
set "MINGW_GFORTRAN=!MINGW_GFORTRAN:\=/!"
:: Keep CMake's Visual Studio Fortran check from selecting the MinGW compiler.
:: CMakeAddFortranSubdirectory passes MINGW_GFORTRAN to the ExternalProject.
set "FC="

set "BUILD_DIR=%SRC_DIR%\..\build_energyplus"
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"

"%PREFIX%\python.exe" "%RECIPE_DIR%\prepare.py" patch
if errorlevel 1 exit /b 1

cmake %CMAKE_ARGS% ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_C_COMPILER=cl ^
  -DCMAKE_CXX_COMPILER=cl ^
  -DMINGW_GFORTRAN="%MINGW_GFORTRAN%" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_FORTRAN=ON ^
  -DOPENGL_REQUIRED=OFF ^
  -DDOCUMENTATION_BUILD=DoNotBuild ^
  -DBUILD_TESTING=OFF ^
  -DBUILD_PACKAGE=ON ^
  -DLINK_WITH_PYTHON=ON ^
  -DPYTHON_CLI=OFF ^
  -DPython_ROOT_DIR="%PREFIX%" ^
  -DPython_FIND_STRATEGY=LOCATION ^
  -B "%BUILD_DIR%" ^
  -S "%SRC_DIR%"
if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --config Release -j %CPU_COUNT%
if errorlevel 1 exit /b 1
cmake --install "%BUILD_DIR%" --config Release --prefix "%PREFIX%\Library"
if errorlevel 1 exit /b 1

:: NO_EXTERNAL_INSTALL requires installing the Fortran subprojects separately.
for %%P in (ReadVars ExpandObjects Slab Basement) do (
  if exist "%BUILD_DIR%\src\%%P" (
    cmake --install "%BUILD_DIR%\src\%%P" --config Release --prefix "%PREFIX%\Library"
    if errorlevel 1 exit /b 1
  )
)
"%PREFIX%\python.exe" "%RECIPE_DIR%\prepare.py" clean "%BUILD_DIR%"
if errorlevel 1 exit /b 1

"%PREFIX%\python.exe" "%RECIPE_DIR%\prepare.py" windows-paths
if errorlevel 1 exit /b 1
