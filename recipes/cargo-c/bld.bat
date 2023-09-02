echo ON

cargo install --path . --root %LIBRARY_PREFIX%
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1
