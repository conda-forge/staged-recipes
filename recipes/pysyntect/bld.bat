REM Print Rust version
rustc --version
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
