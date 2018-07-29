cargo build --release
cargo install --root "%PREFIX%"
IF %ERRORLEVEL% NEQ 0 exit 1
