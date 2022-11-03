set PBR_VERSION=%PKG_VERSION%
cd jpy
REM Use PEP517 to install the package
%PYTHON% setup.py bdist_wheel
REM Install wheel
cd dist
FOR %%w in (*.whl) DO %PYTHON% -m pip install %%w