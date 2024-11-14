set CARGO_HOME=D:\cargo
cargo install --locked --bins --root %PREFIX% yazi-fm yazi-cli
if %errorlevel% NEQ 0 exit /b %errorlevel%
cargo-bundle-licenses --format yaml --output %SRC_DIR%/THIRDPARTY.yml
if %errorlevel% NEQ 0 exit /b %errorlevel%
del %PREFIX%\.crates2.json
if %errorlevel% NEQ 0 exit /b %errorlevel%
del %PREFIX%\.crates.toml
if %errorlevel% NEQ 0 exit /b %errorlevel%
