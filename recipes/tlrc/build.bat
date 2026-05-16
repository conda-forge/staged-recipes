@echo on

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo auditable install --locked --no-track --bins --root "%LIBRARY_PREFIX%" --path . || goto :error

mkdir "%LIBRARY_PREFIX%\share\licenses\tlrc" 2>nul
copy LICENSE "%LIBRARY_PREFIX%\share\licenses\tlrc\" >nul
copy THIRDPARTY.yml "%LIBRARY_PREFIX%\share\licenses\tlrc\" >nul

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
