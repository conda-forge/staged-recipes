@echo on
:: Windows build script
:: Inspired by the numpy-feedstock build script:
:: https://github.com/conda-forge/numpy-feedstock/blob/main/recipe/bld.bat

mkdir builddir
:: https://pypi.org/project/build/
:: python -m build -w -n -x flags mean: --wheel --no-isolation --skip-dependency-check -Cbuilddir=builddir
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir
if %ERRORLEVEL% neq 0 (
    echo "[ERROR] Build failed."
    exit /b 1
)

:: Ensure the dist folder exists before attempting to install
if not exist dist (
    echo "[ERROR] No dist/ directory found."
    exit /b 1
)

:: Check any wheel files were created
:: Install generated wheel(s) from the dist/ folder
set WHEEL_FOUND=0
:: `pip install dist\*.whl` does not work on windows, so use a loop; there's only one wheel in dist/ anyway
:: for %%f in (...)	            Iterate over files or hardcoded items
:: for /f %%f in ('command')	Iterate over command output (or lines in a file)
for /f "delims=" %%f in ('dir /b /s .\dist\*.whl 2^>nul') do (
    set WHEEL_FOUND=1
    echo [INFO] Installing wheel: %%f
    pip install %%f
    if errorlevel 1 (
        echo [ERROR] pip install failed for: %%f
        exit /b 1
    )
)

:: Check if any wheel files were found
IF %WHEEL_FOUND%=="0" (
    echo "[ERROR] No wheel files found in dist/."
    exit /b 0
)
echo "[SUCCESS] Wheel(s) installed successfully."
exit /b 0
