@echo on
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"
if errorlevel 1 exit /b 1
cargo install --locked --no-track --bin bless --root "%LIBRARY_PREFIX%" --path .
if errorlevel 1 exit /b 1
if not exist "%LIBRARY_PREFIX%\bin\bless.exe" exit /b 1
