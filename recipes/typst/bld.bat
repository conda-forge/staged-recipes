cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY_LICENSES.yaml || goto :error

cargo install --locked --root "%PREFIX%" --path .\crates\typst-cli || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
