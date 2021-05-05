cd tensorboard/data/server/pip_package
%PYTHON% build.py --universal --out-dir="%SRC_DIR%/"
if errorlevel 1 exit 1
%PYTHON% -m pip install --no-deps --ignore-installed -v "%SRC_DIR%/%WHEELNAME%"
if errorlevel 1 exit 1
