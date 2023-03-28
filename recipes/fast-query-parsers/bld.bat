@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP="%SRC_DIR%\tmpbuild_%PY_VER%"

mkdir "%TEMP%"

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

:: call "%PYTHON%" -m maturin build --release --strip -i "%PYTHON%" ^
maturin build -v --jobs 1 --release --strip --interpreter=%PYTHON% ^
    || exit 1

chcp 65001

"%PYTHON%" -m pip install fast-query-parsers -vv --no-index --find-links "%SRC_DIR%\target\wheels" ^
    || exit 1
