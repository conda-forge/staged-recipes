cargo install --locked --root "%LIBRARY_PREFIX%" --path . || goto :error

strip "%LIBRARY_PREFIX%\bin\ffsend.exe" || goto :error

del /F /Q "%LIBRARY_PREFIX%\.crates.toml"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
