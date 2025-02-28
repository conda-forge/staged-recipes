cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY_LICENSES.yaml || goto :error

cargo install --no-track --locked --root "%LIBRARY_PREFIX%" --path crates\tytanic || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
