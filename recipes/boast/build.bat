set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cargo auditable install --locked --no-track --bins --root %LIBRARY_PREFIX% --path .
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1
