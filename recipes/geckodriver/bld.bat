@ECHO ON
cargo build --release
IF ERRORLEVEL 1 EXIT /B 1
cargo install --bin %PKG_NAME% --root %PREFIX%
IF ERRORLEVEL 1 EXIT /B 1
DEL /F /Q %PREFIX%\.crates.toml
