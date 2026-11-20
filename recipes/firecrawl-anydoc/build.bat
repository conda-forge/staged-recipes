set "CARGO_HOME=%SRC_DIR%\.cargo"
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit /b 1
python -m pip install . --no-deps --no-build-isolation -vv
if errorlevel 1 exit /b 1
