@echo on

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit /b 1

if defined CARGO_BUILD_TARGET (
    cargo auditable install --no-track --locked --root "%PREFIX%" --path . --target "%CARGO_BUILD_TARGET%" || exit /b 1
) else (
    cargo auditable install --no-track --locked --root "%PREFIX%" --path . || exit /b 1
)

exit /b 0
