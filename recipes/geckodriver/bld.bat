@ECHO ON
rustc -V
cargo -V
cargo build --release --verbose
IF ERRORLEVEL 1 EXIT /B 1
cargo install --bin %PKG_NAME% --root %PREFIX%
IF ERRORLEVEL 1 EXIT /B 1
DEL /F /Q %PREFIX%\.crates.toml
