cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error
cargo install --locked --root "%LIBRARY_PREFIX%" --path . || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
