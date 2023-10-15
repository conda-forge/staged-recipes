:: Install libxml dependencies
:: Rust crate libxml favors LIBXML2 over vcpkg if LIBXML2 is not empty.
set LIBXML2=
set VCPKG_ROOT=C:\vcpkg
set VCPKGRS_DYNAMIC=1

:: We don't need libxml2 lzma and zlib features.
vcpkg install libxml2[core,iconv] --triplet x64-windows

:: Check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: Build
cargo install --locked --root "%LIBRARY_PREFIX%" --path packages/hurl || goto :error
cargo install --locked --root "%LIBRARY_PREFIX%" --path packages/hurlfmt || goto :error

:: Remove extra build files
del /F /Q "%LIBRARY_PREFIX%\.crates.toml"
del /F /Q "%LIBRARY_PREFIX%\.crates2.json"

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
