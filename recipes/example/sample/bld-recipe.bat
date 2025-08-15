@echo on
REM -----------------------------------------------------------------------------
REM Windows build script for Conda (bld.bat)
REM -----------------------------------------------------------------------------
REM Inspired by the numpy-feedstock build script:
REM https://github.com/conda-forge/numpy-feedstock/blob/main/recipe/bld.bat
REM
REM Notes:
REM - Comment '::' must be at the start of a line (not indented), or CMD may interpret it as a label and behave strangely.
REM - Use 'REM' for safe comments anywhere in the script
REM - Use '|| exit /b N' for consistent error handling
REM -----------------------------------------------------------------------------

REM Ensure submodules are initialized (e.g., if using git submodules)
REM git submodule update --init --recursive || exit /b 1
git submodule update --init --recursive || exit /b 0

REM 🚫 You should list each of the submodules in the source section.
REM Example: https://github.com/conda-forge/tomopy-feedstock/blob/fc6617f1a97e866ff3d78c67c71b5d9fa76bc4fc/recipe/meta.yaml#L42



REM Create a clean build directory
mkdir builddir || exit /b 0

REM Build a wheel without isolation and skipping dependency checks
REM Flags:
REM   -w: build wheel
REM   -n: no isolation
REM   -x: skip dependency checks
REM %PYTHON% -m build -w -n -x -Cbuilddir=builddir
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir 
if %ERRORLEVEL% neq 0 exit /b 1

REM ---------------------------------------------------------------------------
REM Install generated wheel(s) from the dist/ folder
REM ---------------------------------------------------------------------------

REM Ensure the dist folder exists
if not exist dist (
    echo ERROR: No dist/ directory found.
    exit /b 1
)

REM Get a list of .whl files (full paths)
set "WHEEL_FOUND=0"

REM Additional build commands, e.g., python setup.py install
REM `pip install dist\*.whl` does not work on windows,
REM so use a loop; there's only one wheel in dist/ anyway
REM for %%f in (...)	Iterate over files or hardcoded items
REM for /f %%f in ('command')	Iterate over command output (or lines in a file)
for /f "delims=" %%f in ('dir /b /s dist\*.whl 2^>nul') do (
    echo [INFO] Installing wheel: %%f
    pip install "%%f"
    if errorlevel 1 (
        echo [ERROR] pip install failed for: %%f
        exit /b 1
    )
    set WHEEL_FOUND=1
)

REM Check if any wheel was installed
IF "%WHEEL_FOUND%"=="0" (
    echo [ERROR] No wheel files found in dist/.
    exit /b 0
)

REM Success
echo [SUCCESS] Wheel(s) installed successfully.

exit /b 0
