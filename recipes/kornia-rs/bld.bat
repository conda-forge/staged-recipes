REM Create temp folder
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%
REM Bundle all downstream library licenses
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY_LICENSES.yaml ^
    || goto :error
REM Build the wheels
maturin build --release -i %PYTHON%
REM Install wheel
cd kornia-py/target/wheels
REM set UTF-8 mode by default
chcp 65001
set PYTHONUTF8=1
set PYTHONIOENCODING="UTF-8"
set TMPDIR=tmpbuild_%PY_VER%
FOR %%w in (*.whl) DO %PYTHON% -m pip install %%w --no-clean