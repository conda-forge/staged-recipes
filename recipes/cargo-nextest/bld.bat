:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: build
cargo install --locked --root "%PREFIX%" --path cargo-nextest || goto :error

:: strip debug symbols
strip "%PREFIX%\bin\cargo-nextest.exe" || goto :error

:: remove extra build file
del /F /Q "%PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
