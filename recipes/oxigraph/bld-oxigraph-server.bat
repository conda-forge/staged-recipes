@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%

mkdir %TEMP%

rustc --version

cd %SRC_DIR%\server

cargo build --release --verbose || exit 1

if not exist "%SCRIPTS%" mkdir %SCRIPTS%

copy %SRC_DIR%\target\release\oxigraph_server %SCRIPTS% || exit 1
