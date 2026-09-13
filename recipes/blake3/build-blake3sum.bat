cd "%SRC_DIR%\b3sum"

cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"
if errorlevel 1 exit 1

cargo install --locked --no-track --root "%LIBRARY_PREFIX%" --path .
if errorlevel 1 exit 1
