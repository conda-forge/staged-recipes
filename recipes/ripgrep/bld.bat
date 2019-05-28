:: build
cargo build   --features pcre2 --release                  || goto :error
cargo install --features pcre2 --root "%PREFIX%" --path . || goto :error

:: strip debug symbols
strip "%PREFIX%\bin\rg.exe" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
