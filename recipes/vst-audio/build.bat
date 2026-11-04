@echo on
if not defined CARGO_BUILD_TARGET exit /b 1
set "CARGO_HOME=%SRC_DIR%\.cargo-home"
set "CARGO_TARGET_DIR=%SRC_DIR%\target"
set "CARGO_BUILD_JOBS=%CPU_COUNT%"
set "CARGO_PROFILE_RELEASE_STRIP=symbols"
set "MATURIN_PEP517_ARGS=--locked --target %CARGO_BUILD_TARGET%"

cargo-bundle-licenses --format yaml --output THIRDPARTY-worker.yml
if errorlevel 1 exit /b 1

"%PYTHON%" bindings\python\stage_worker.py
if errorlevel 1 exit /b 1

cd bindings\python
if errorlevel 1 exit /b 1
cargo-bundle-licenses --format yaml --output THIRDPARTY-extension.yml
if errorlevel 1 exit /b 1
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit /b 1
