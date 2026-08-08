@echo on
setlocal enabledelayedexpansion

REM Fix HOME for git config (CI sets it to Unix-style path that doesn't exist on Windows)
set "HOME=%USERPROFILE%"

REM Enable long paths for Git/libgit2 (required even if OS-level long paths are enabled)
git config --global core.longpaths true

cd codex-rs
cargo-bundle-licenses --format yaml --output ..\THIRDPARTY.yml

if not defined CARGO_BUILD_TARGET (
    if "%target_platform%"=="win-arm64" (
        set "CARGO_BUILD_TARGET=aarch64-pc-windows-msvc"
    ) else if "%target_platform%"=="win-64" (
        set "CARGO_BUILD_TARGET=x86_64-pc-windows-msvc"
    )
)

REM Open Interpreter's upstream package variant builds the Cargo bin named
REM "codex", then exposes it as "interpreter" with "i" as an alias.
if defined CARGO_BUILD_TARGET (
    echo Building for target: %CARGO_BUILD_TARGET%
    cargo auditable install --locked --no-track --bins --root "%PREFIX%" --path cli --target %CARGO_BUILD_TARGET%
) else (
    cargo auditable install --locked --no-track --bins --root "%PREFIX%" --path cli
)

move "%PREFIX%\bin\codex.exe" "%PREFIX%\bin\interpreter.exe"
copy /Y "%PREFIX%\bin\interpreter.exe" "%PREFIX%\bin\i.exe"

REM Pixi: prevent CONDA_PREFIX from leaking into sandboxed processes
set "MARKER_DIR=%PREFIX%\etc\pixi\interpreter"
if not exist "%MARKER_DIR%" mkdir "%MARKER_DIR%" 2>nul
type nul > "%MARKER_DIR%\global-ignore-conda-prefix"

set "MARKER_DIR=%PREFIX%\etc\pixi\i"
if not exist "%MARKER_DIR%" mkdir "%MARKER_DIR%" 2>nul
type nul > "%MARKER_DIR%\global-ignore-conda-prefix"

endlocal
exit /b 0
