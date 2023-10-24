setlocal EnableDelayedExpansion

REM Build Python wheel
%PYTHON% -m pip wheel -w .\wheel .\build\api\swig\python
if errorlevel 1 exit /b 1

REM Install it
for %%w in (.\wheel\bagPy-*.whl) do %PYTHON% -m pip install %%w
if errorlevel 1 exit /b 1
