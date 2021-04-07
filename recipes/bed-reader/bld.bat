REM Based on bld.bat from pysyntect-feedstock
REM https://github.com/conda-forge/pysyntect-feedstock/

REM Create temp folder
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%
REM Print Rust version
rustc --version

REM Use PEP517 to install the package
maturin build --release -i %PYTHON%
REM Install wheel
cd target/wheels
REM set UTF-8 mode by default
chcp 65001
set PYTHONUTF8=1
set PYTHONIOENCODING="UTF-8"
FOR %%w in (*.whl) DO %PYTHON% -m pip install %%w --build tmpbuild_%PY_VER%
