:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || goto :error

:: build
cargo install --locked --root "%LIBRARY_PREFIX%" --path . || goto :error

:: strip debug symbols
%STRIP% %LIBRARY_PREFIX%\bin\%PKG_NAME%.exe || goto :error
%STRIP% %LIBRARY_PREFIX%\bin\sg.exe || goto :error

:: remove extra build file
del /F /Q "%LIBRARY_PREFIX%\.crates.toml" || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
