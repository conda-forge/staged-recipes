@ECHO ON
setlocal EnableDelayedExpansion

:: Ensure LOCALAPPDATA is defined
if not defined LOCALAPPDATA set "LOCALAPPDATA=%USERPROFILE%\AppData\Local"

:: Bypass the ort-sys build script by overriding its 'ort' links entry with
:: empty linker flags. ort-sys v2.x uses `links = "ort"` in Cargo.toml.
:: The build script calls dirs::cache_dir() (via SHGetKnownFolderPath) which
:: fails for non-first Python variant builds in CI. fastembed uses ort's
:: load-dynamic Cargo feature so no compile-time linking is needed.
if not exist "%SRC_DIR%\.cargo" mkdir "%SRC_DIR%\.cargo"
echo [target.x86_64-pc-windows-msvc.ort]>"%SRC_DIR%\.cargo\config.toml"
echo rustc-link-lib = []>>"%SRC_DIR%\.cargo\config.toml"

set "PYTHONUTF8=1"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1

python -m pip install . --no-build-isolation -vv
if errorlevel 1 exit /b 1
