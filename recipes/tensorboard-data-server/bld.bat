cd tensorboard/data/server/pip_package

rem Remove unnecessary line from build.py to work around PermissionError: [WinError 32] The process cannot access the file because it is being used by another process
findstr /v /L /c:"shutil.rmtree(tmpdir)" build.py > _build.py
if errorlevel 1 exit 1
del build.py
if errorlevel 1 exit 1
ren _build.py build.py
if errorlevel 1 exit 1

%PYTHON% build.py --universal --out-dir="%TEMP%/"
if errorlevel 1 exit 1
%PYTHON% -m pip install --no-deps --ignore-installed -v "%TEMP%/%WHEELNAME%"
if errorlevel 1 exit 1
