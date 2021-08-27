@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%

mkdir %TEMP%

rustc --version

cd %SRC_DIR%\python

maturin build --release -i %PYTHON% || exit 1

chcp 65001

FOR %%w IN (%SRC_DIR%\target\wheels\*.whl) DO (
    %PYTHON% -m pip install %%w --build %TEMP% || exit 1
)

del /F /Q "%PREFIX%\.crates2.json"
del /F /Q "%PREFIX%\.crates.toml"
