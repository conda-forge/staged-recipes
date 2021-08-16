REM Based on bld.bat from pysyntect-feedstock
REM https://github.com/conda-forge/pysyntect-feedstock/

REM Create temp folder
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%
REM Print Rust version
rustc --version

cd python

REM Use PEP517 to install the package
maturin build --release -i %PYTHON%
