@echo on

set OPENSSL_NO_VENDOR=1
set "OPENSSL_DIR=%LIBRARY_PREFIX%"

cargo-bundle-licenses ^
    --format yaml ^
    --output THIRDPARTY_LICENSES.yaml || goto :error

cargo install --locked --root "%PREFIX%" --path .\tools\cli || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
