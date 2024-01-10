:: build
cargo install --locked --root "%PREFIX%" --path . || exit 1

:: move to scripts
md "%SCRIPTS%" || echo "%SCRIPTS% already exists"
move "%PREFIX%\bin\vale-ls.exe" "%SCRIPTS%"

:: dump licenses
cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"

:: remove extra build files
del /F /Q "%PREFIX%\.crates2.json"
del /F /Q "%PREFIX%\.crates.toml"
