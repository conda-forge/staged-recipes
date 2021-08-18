@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%

mkdir %TEMP%

IF %PKG_NAME% eq "oxigraph-server" (
    cd server
        cargo build --release || exit 1
    cd %SRC_DIR%

    dir target/release

    copy target/release/oxigraph_server %SCRIPTS%
)

IF %PKG_NAME% eq "pyoxigraph" (
    cd %SRC_DIR%\python
        maturin build --release -i %PYTHON% || exit 1
    cd %SRC_DIR%

    dir target/wheels

    cd target/wheels
        chcp 65001
        FOR %%w IN (*.whl) DO (
            %PYTHON% -m pip install %%w --build tmpbuild_%PY_VER%
        )
    cd %SRC_DIR%
)
