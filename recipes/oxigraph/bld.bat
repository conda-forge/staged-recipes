@echo on

set RUST_BACKTRACE=1
set TEMP=%CD%\tmpbuild_%PY_VER%

mkdir %TEMP%

cd python
    maturin build --release -i %PYTHON% || exit 1
cd %SRC_DIR%

cd server
    cargo build --release || exit 1
cd %SRC_DIR%

cd wikibase
    cargo build --release || exit 1
cd %SRC_DIR%

dir target/release
dir target/wheels
