@ECHO ON
setlocal EnableDelayedExpansion

:: Ensure LOCALAPPDATA is defined
if not defined LOCALAPPDATA set "LOCALAPPDATA=%USERPROFILE%\AppData\Local"

:: Bypass the ort-sys build script by overriding its 'onnxruntime' links entry
:: with empty linker flags. The build script calls dirs::cache_dir() (via the
:: Windows API SHGetKnownFolderPath) which fails for non-first Python variants
:: in the same CI job. fastembed uses ort's load-dynamic Cargo feature so no
:: compile-time link against onnxruntime is required — ORT is loaded at runtime.
if not exist "%SRC_DIR%\.cargo" mkdir "%SRC_DIR%\.cargo"
echo [target.x86_64-pc-windows-msvc.onnxruntime]>"%SRC_DIR%\.cargo\config.toml"
echo rustc-flags = "">>"%SRC_DIR%\.cargo\config.toml"

set "PYTHONUTF8=1"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1

python -m pip install . --no-build-isolation -vv
if errorlevel 1 exit /b 1
