:: check licenses
cargo-bundle-licenses --format yaml --output CI.THIRDPARTY.yml --previous "%RECIPE_DIR%\THIRDPARTY.yml" --check-previous

:: build
cargo install --locked --root "%LIBRARY_PREFIX%" --path . || goto :error

:: strip debug symbols
strip "%LIBRARY_PREFIX%\bin\just.exe" || goto :error

:: remove extra build file
del /F /Q "%LIBRARY_PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1