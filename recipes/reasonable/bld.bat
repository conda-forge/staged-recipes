@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%
set PYO3_PYTHON=%PYTHON%

mkdir %TEMP%

rustc --version

maturin build ^
    --release ^
    -i %PYTHON% ^
    -b pyo3 ^
    --cargo-extra-args="--features python-library" ^
    || exit 1

:: dump licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY.yml ^
    || exit 1

chcp 65001

:: TODO: remove this: not sure what the TEMP was doing, but fails py310
:: %PYTHON% -m pip install %%w --build %TEMP% || exit 1

FOR %%w IN (%SRC_DIR%\target\wheels\*.whl) DO (
    %PYTHON% -m pip install %%w || exit 1
)

del /F /Q "%PREFIX%\.crates2.json"
del /F /Q "%PREFIX%\.crates.toml"
