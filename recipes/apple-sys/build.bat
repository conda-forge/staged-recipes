@echo off

call cargo build --release --all-targets
call cargo test --release --all-targets
call cargo install --path . --root "%PREFIX%" --features="bin"
call cargo-bundle-licenses --format yaml --output "%RECIPE_DIR%\THIRDPARTY.yml"
