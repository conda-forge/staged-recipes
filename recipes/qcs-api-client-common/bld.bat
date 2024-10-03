@echo off

maturin build --release --manifest-path %SRC_DIR%\qcs-api-client-common\Cargo.toml --out %SRC_DIR%\wheels

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
