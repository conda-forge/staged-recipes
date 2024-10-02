:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: build
cargo install --locked --root "%PREFIX%" --path cargo-nextest --no-track || goto :error

:: strip debug symbols
strip "%PREFIX%\bin\cargo-nextest.exe" || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
