@echo off
REM Get Python version from conda-build environment (e.g., 3.11, 3.12, 3.13)
set PYTHON_VERSION=%PY_VER%

set CUIKMOLMAKER_CXX11_ABI=ON

REM Validate RDKit version format (year.minor.patch)
echo RDKIT_VERSION=%RDKIT_VERSION%
echo PYTHON_VERSION=%PYTHON_VERSION%

echo CONDA_PREFIX:
echo %CONDA_PREFIX%
echo BUILD_PREFIX:
echo %BUILD_PREFIX%

REM Build C++ extension
%PYTHON% setup.py build_ext --inplace
if errorlevel 1 exit 1

REM Set the wheel directory
set WHL_DIR=cm_py%PYTHON_VERSION%_rdkit-%RDKIT_VERSION%_dist

REM Build wheel
%PYTHON% setup.py bdist_wheel --dist-dir %WHL_DIR%

for %%f in ("%WHL_DIR%\*.whl") do (
    set "WHL_FILE=%%f"
    goto found_whl
)

:found_whl
%PYTHON% -m pip install --no-deps --no-build-isolation --prefix=%PREFIX% "%WHL_FILE%"
if errorlevel 1 exit 1


echo PREFIX:
echo %PREFIX%

