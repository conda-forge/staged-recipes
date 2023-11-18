:: libxml Rust crate uses LIBXML2 env var to build.
set LIBXML2=%BUILD_PREFIX%\Library\lib\libxml2.lib

:: Check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: Build
cargo install --locked --root "%LIBRARY_PREFIX%" --path packages/hurl || goto :error
cargo install --locked --root "%LIBRARY_PREFIX%" --path packages/hurlfmt || goto :error

:: Remove extra build files
del /F /Q %LIBRARY_PREFIX%\.crates.toml
del /F /Q %LIBRARY_PREFIX%\.crates2.json

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
