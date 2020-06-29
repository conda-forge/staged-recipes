@echo on

:: Create temp folder
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%

:: Print Rust version
rustc --version

:: Install cargo-license
set CARGO_HOME=%BUILD_PREFIX%\cargo
mkdir %CARGO_HOME%
icacls %CARGO_HOME% /grant Users:F
cargo install cargo-license || goto :error

:: Check that all downstream libraries licenses are present
set PATH=%PATH%;%CARGO_HOME%\bin
cargo-license --json > dependencies.json || goto :error
type dependencies.json || goto :error
python %RECIPE_DIR%\check_licenses.py || goto :error

:: build
cargo build --release || goto :error

:: this can fail, but copying might still work
md "%PREFIX%\Scripts\"

:: TODO: remove debugging
dir "target\release\"

copy "target\release\%PKG_NAME%.exe" "%PREFIX%\Scripts\%PKG_NAME%.exe" || goto :error

:: TODO: remove debugging
dir "%PREFIX%\Scripts\%PKG_NAME%.exe"

goto :EOF

:error
echo FAIL Building %PKG_NAME% with error #%errorlevel%.
exit /b %errorlevel%
