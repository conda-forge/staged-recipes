cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY_LICENSES.yaml || goto :error

cargo install --no-track --locked --root "%PREFIX%" --path . || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
