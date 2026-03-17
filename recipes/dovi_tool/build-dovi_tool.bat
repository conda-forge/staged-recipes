@echo on
setlocal

cd /D %SRC_DIR%\dovi_tool_src
if errorlevel 1 exit /b 1

if not defined CARGO_BUILD_TARGET if defined RUST_TARGET set "CARGO_BUILD_TARGET=%RUST_TARGET%"

set "CARGO_PROFILE_RELEASE_STRIP=symbols"
set "CARGO_PROFILE_RELEASE_LTO=thin"

cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY_dovi_tool.yml"
if errorlevel 1 exit /b 1

cargo auditable install --locked --no-track --bins --root "%LIBRARY_PREFIX%" --path .
if errorlevel 1 exit /b 1
