:: check licenses
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

:: build
cargo install --locked --root "%PREFIX%" --path cargo-insta --no-track || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
