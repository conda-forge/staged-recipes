@echo on

:: Remove vendored carma so the conda-forge host package is used instead
if exist carma rmdir /s /q carma

set "INCLUDE=%LIBRARY_INC%\carma;%LIBRARY_INC%;%INCLUDE%"
set "LIB=%LIBRARY_LIB%;%LIB%"

set "ARMADILLO_INCLUDE_DIR=%LIBRARY_INC%"
set "ARMADILLO_LIB_DIR=%LIBRARY_LIB%"

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1