cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if %errorlevel% neq 0 exit /b %errorlevel%
cargo install --locked --bins --root %PREFIX% --path .
if %errorlevel% neq 0 exit /b %errorlevel%
del %PREFIX%\.crates2.json
if %errorlevel% neq 0 exit /b %errorlevel%
del %PREFIX%\.crates.toml
if %errorlevel% neq 0 exit /b %errorlevel%
