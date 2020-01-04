:: build
cargo install --features=all --root "%PREFIX%" --path . || goto :error

:: strip debug symbols
strip "%PREFIX%\bin\sccache.exe" || goto :error

:: remove extra build file
del /F /Q "%PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
