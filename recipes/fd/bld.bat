:: build
cargo build   --release                  || goto :error
cargo install --root "%PREFIX%" --path . || goto :error

:: strip debug symbols
strip "%PREFIX%\bin\fd.exe" || goto :error
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
