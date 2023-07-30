@ECHO ON

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

cargo build --release --all-features
if %ERRORLEVEL% neq 0 (type CMakeError.log && exit 1)

dir target\
