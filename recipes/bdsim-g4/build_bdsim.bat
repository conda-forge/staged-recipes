@echo on
setlocal enabledelayedexpansion
set "SRC_DIR=%SRC_DIR:\=/%"
set "PREFIX=%PREFIX:\=/%"

mkdir bdsim-build
cd bdsim-build

cmake %CMAKE_ARGS% -DCMAKE_PREFIX_PATH=%PREFIX%/lib/cmake/Geant4/ ^
                   -DCMAKE_INSTALL_PREFIX=%PREFIX% ^
                   %SRC_DIR%

cmake --build . --parallel %CPU_COUNT%
cmake --install . --prefix %PREFIX%

REM Remove original script and replace with Windows-friendly dummy
del %PREFIX%\bin\bdsim.sh
copy %RECIPE_DIR%\bdsim.bat %PREFIX%\bin\bdsim.bat
