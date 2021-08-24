@echo on

set PYTHONIOENCODING="UTF-8"
set PYTHONUTF8=1
set RUST_BACKTRACE=1
set TEMP=%SRC_DIR%\tmpbuild_%PY_VER%

mkdir %TEMP%

rustc --version

IF "%PKG_NAME%" == "oxigraph-server" (
    cd server
    cargo build --release --verbose || exit 1
    copy %SRC_DIR%\target\release\oxigraph_server %SCRIPTS%
    goto :eof
)

IF "%PKG_NAME%" == "oxigraph-wikibase" (
    cd wikibase
    cargo build --release || exit 1
    copy %SRC_DIR%\target\release\oxigraph_wikibase %SCRIPTS%
    goto :eof
)

IF "%PKG_NAME%" == "pyoxigraph" (
    cd %SRC_DIR%\python
    maturin build --release -i %PYTHON% || exit 1
    chcp 65001
    FOR %%w IN (%SRC_DIR%\target\wheels\*.whl) DO (
        %PYTHON% -m pip install %%w --build %TEMP%
    )
    goto :eof
)
