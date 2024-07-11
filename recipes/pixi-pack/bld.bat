cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
cargo install --locked --root "%LIBRARY_PREFIX%" --path . || goto :error
strip "%LIBRARY_PREFIX%\bin\pixi-pack.exe" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
