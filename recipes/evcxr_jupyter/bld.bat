:: build
cargo install --root "%PREFIX%" --path .\evcxr_jupyter || goto :error

:: strip debug symbols
strip "%PREFIX%\bin\evcxr_jupyter.exe" || goto :error

:: remove extra build file
del /F /Q "%PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
