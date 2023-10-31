@echo on

setlocal EnableDelayedExpansion

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

for %%F in (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
    copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)