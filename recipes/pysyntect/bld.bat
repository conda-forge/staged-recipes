REM Print Rust version
rustc --version
REM Install cargo-license
set CARGO_HOME="%BUILD_PREFIX%\cargo"
mkdir CARGO_HOME
cargo install cargo-license
REM Check that all downstream libraries licenses are present
set PATH=%PATH%;%CARGO_HOME%\bin
cargo-license --json > dependencies.json
python %RECIPE_DIR%\check_licenses.py
REM Use PEP517 to install the package
REM pip install -U . --no-build-isolation
maturin build --release -i %PYTHON%
REM Install wheel
cd target/wheels
REM set UTF-8 mode by default
chcp 65001
set PYTHONUTF8=1
set PYTHONIOENCODING="UTF-8"
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%
FOR %%w in (*.whl) DO pip install %%w --build tmpbuild_%PY_VER%
