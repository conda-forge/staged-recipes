REM Let R determine build target
set CARGO_BUILD_TARGET=

"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1

REM Bundle third party licenses from statically linked crates
pushd src/rust
cargo-bundle-licenses --format yaml --output "%SRC_DIR%/THIRDPARTY.yml"
popd
