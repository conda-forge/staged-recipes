@echo off
setlocal EnableDelayedExpansion

REM Set environment variables for Rust build
set CARGO_TARGET_DIR=%SRC_DIR%\rust\target\conda
set PYO3_USE_ABI3_FORWARD_COMPATIBILITY=1

REM Ensure we're in the source directory
cd /d "%SRC_DIR%"

REM Change to rust directory for building
cd rust

REM Bundle licenses before building
echo Bundling Rust dependency licenses...
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"
if errorlevel 1 (
    echo License bundling failed!
    exit /b 1
)

REM Build with maturin
echo Building Rust extension with maturin...
maturin build --release --features python --out dist
if errorlevel 1 (
    echo Build failed!
    exit /b 1
)

REM Install the wheel
echo Installing built wheel...
for %%f in (dist\*.whl) do (
    %PYTHON% -m pip install "%%f" --no-deps --ignore-installed -vv
    if errorlevel 1 (
        echo Installation failed!
        exit /b 1
    )
    goto :wheel_installed
)
echo No wheel file found in dist directory!
exit /b 1
:wheel_installed

REM Copy Python package files to site-packages (only if not already in wheel)
echo Installing Python package files...
for /f "delims=" %%i in ('%PYTHON% -c "import site; print(site.getsitepackages()[0])"') do set PYTHON_SITE_PACKAGES=%%i
if not exist "%PYTHON_SITE_PACKAGES%\polytri" mkdir "%PYTHON_SITE_PACKAGES%\polytri"
REM Only copy files that don't exist yet to avoid overwriting the Rust module
for %%f in ("%SRC_DIR%\polytri\*") do (
    if not exist "%PYTHON_SITE_PACKAGES%\polytri\%%~nxf" (
        xcopy "%SRC_DIR%\polytri\*" "%PYTHON_SITE_PACKAGES%\polytri\" /E /Y /I
    )
)

REM Verify installation
echo Verifying installation...
%PYTHON% -c "import polytri; print('polytri imported successfully, Rust available:', polytri._rust_available)"

echo Build completed successfully!

