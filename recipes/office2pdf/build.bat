tar -xzf office2pdf-cli-%PKG_VERSION%.tar.gz
if errorlevel 1 exit 1

cd office2pdf-cli-%PKG_VERSION%
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output %SRC_DIR%\THIRDPARTY.yml
if errorlevel 1 exit 1

cargo install --locked --no-track --root %PREFIX% --path .
if errorlevel 1 exit 1
