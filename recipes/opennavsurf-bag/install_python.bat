setlocal EnableDelayedExpansion

REM Build Python wheel
for /F "tokens=2" %%v in ('python -V') DO set WHEEL_DIR=.\wheel-%%v
%PYTHON% -m pip wheel -w %WHEEL_DIR% .\build\api\swig\python
if errorlevel 1 exit /b 1

REM Install it
for %%w in (%WHEEL_DIR%\bagPy-*.whl) do %PYTHON% -m pip install %%w
if errorlevel 1 exit /b 1
