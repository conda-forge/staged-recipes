@echo off
setlocal EnableDelayedExpansion

REM Set environment variables for Rust build
set CARGO_TARGET_DIR=%SRC_DIR%\rust\target\conda
set PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

REM Ensure we're in the source directory
cd /d "%SRC_DIR%"

REM Change to rust directory for building
cd rust

REM Build with maturin
echo Building Rust extension with maturin...
maturin build --release --features python --out dist
if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

REM Install the wheel
echo Installing built wheel...
%PYTHON% -m pip install dist\*.whl --no-deps --ignore-installed -vv
if errorlevel 1 (
    echo Installation failed!
    exit /b 1
)

REM Copy Python package files to site-packages
echo Installing Python package files...
for /f "delims=" %%i in ('%PYTHON% -c "import site; print(site.getsitepackages()[0])"') do set PYTHON_SITE_PACKAGES=%%i
if not exist "%PYTHON_SITE_PACKAGES%\polytri" mkdir "%PYTHON_SITE_PACKAGES%\polytri"
xcopy /E /I /Y "%SRC_DIR%\polytri\*" "%PYTHON_SITE_PACKAGES%\polytri\"

REM Verify installation
echo Verifying installation...
%PYTHON% -c "import polytri; print('polytri imported successfully, Rust available:', polytri._rust_available)"

echo Build completed successfully!

