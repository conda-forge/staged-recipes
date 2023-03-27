@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP="%SRC_DIR%\tmpbuild_%PY_VER%"

mkdir "%TEMP%"

%PYTHON% -m pip install . -vv --no-build-isolation ^
    || exit 1

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output "%SRC_DIR%\THIRDPARTY.yml" ^
    || exit 1

chcp 65001

"%PYTHON%" -m pip install fast-query-parsers -vv --no-index --find-links "%SRC_DIR%\target\wheels" ^
    || exit 1
