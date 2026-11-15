@echo on
setlocal enabledelayedexpansion

REM Keep Git paths valid and short in Windows CI.
set "HOME=%USERPROFILE%"
set "GIT_CONFIG_COUNT=1"
set "GIT_CONFIG_KEY_0=core.longpaths"
set "GIT_CONFIG_VALUE_0=true"
for %%I in ("%SRC_DIR%") do set "BUILD_DRIVE=%%~dI"
set "CARGO_TARGET_DIR=%BUILD_DRIVE%\oi-target"
set "CARGO_HOME=%BUILD_DRIVE%\oi-cargo"

if not defined CARGO_BUILD_TARGET (
    if "%target_platform%"=="win-arm64" (
        set "CARGO_BUILD_TARGET=aarch64-pc-windows-msvc"
    ) else if "%target_platform%"=="win-64" (
        set "CARGO_BUILD_TARGET=x86_64-pc-windows-msvc"
    )
)

just assemble-codex-package --variant open-interpreter --cargo-profile release --package-dir out --target "%CARGO_BUILD_TARGET%" --rg-bin "%PREFIX%\bin\rg.exe"
if errorlevel 1 exit /b 1
python "%RECIPE_DIR%\install_package.py" out "%PREFIX%"
if errorlevel 1 exit /b 1

cd codex-rs
cargo-bundle-licenses --format yaml --output ..\THIRDPARTY.yml
if errorlevel 1 exit /b 1

endlocal
exit /b 0
