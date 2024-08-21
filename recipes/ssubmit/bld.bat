:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: build
cargo install --locked --no-track  --root "%LIBRARY_PREFIX%" --path . || goto :error

:: strip debug symbols
strip "%LIBRARY_PREFIX%\bin\ssubmit.exe" || goto :error


goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1