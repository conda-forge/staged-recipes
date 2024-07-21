:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

:: build
cargo install --locked --root %LIBRARY_PREFIX% --path %PKG_NAME% || goto :error

:: remove extra build file
del /F /Q "%LIBRARY_PREFIX%\.crates.toml" || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
