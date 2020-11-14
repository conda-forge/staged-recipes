
:: Install cargo-license
set CARGO_HOME=%BUILD_PREFIX%\cargo
mkdir %CARGO_HOME%
icacls %CARGO_HOME% /grant Users:F
cargo install cargo-license --version 0.3.0 --locked
:: Check that all downstream libraries licenses are present
set PATH=%PATH%;%CARGO_HOME%\bin
cargo-license --json > dependencies.json
cat dependencies.json
python %RECIPE_DIR%\check_licenses.py

:: build
cargo install --locked --root "%LIBRARY_PREFIX%" --path .\rage || goto :error

:: strip debug symbols
strip "%LIBRARY_PREFIX%\bin\rage.exe" || goto :error

:: remove extra build file
del /F /Q "%LIBRARY_PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
