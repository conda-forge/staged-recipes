@echo on
%PYTHON% -m pymsbuild wheel
if errorlevel 1 exit 1
%PYTHON% -m pip install dist\pymsbuild-%PKG_VERSION%-py3-none-any.whl
if errorlevel 1 exit 1
