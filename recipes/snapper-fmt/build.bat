@echo on
setlocal EnableDelayedExpansion

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: Write third-party license inventory into the source tree (packaged via license_file).
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"
if errorlevel 1 exit /b 1

:: Public CLIs only (skip snapper-gen-docs). snapper-fmt aliases snapper.
cargo install --locked --no-track --bin snapper --bin snapper-fmt --root "%LIBRARY_PREFIX%" --path .
if errorlevel 1 exit /b 1

if not exist "%LIBRARY_PREFIX%\bin\snapper.exe" (
  echo ERROR: snapper.exe not installed
  exit /b 1
)
if not exist "%LIBRARY_PREFIX%\bin\snapper-fmt.exe" (
  echo ERROR: snapper-fmt.exe not installed
  exit /b 1
)
dir "%SRC_DIR%\LICENSE"
dir "%SRC_DIR%\THIRDPARTY.yml"
