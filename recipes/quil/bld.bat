@echo off
REM Build
call maturin build --release --manifest-path=%SRC_DIR%\quil-py\Cargo.toml --out %SRC_DIR%\wheels
call maturin build --release --manifest-path=%SRC_DIR%\quil-cli\Cargo.toml --out %SRC_DIR%\wheels

call cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
