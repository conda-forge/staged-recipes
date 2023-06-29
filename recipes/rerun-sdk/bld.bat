@echo on

set "PYO3_PYTHON=%PYTHON%"

maturin build --release --interpreter=%PYTHON%  -m rerun_py\Cargo.toml

FOR %%G IN (%SRC_DIR%\target\wheels) DO (
    %PYTHON% -m pip install --ignore-installed --no-deps -vv %%G
)
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1