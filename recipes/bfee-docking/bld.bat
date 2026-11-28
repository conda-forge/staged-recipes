@echo on

if exist bfee_docking\third_party\vina\vina del /f /q bfee_docking\third_party\vina\vina
if errorlevel 1 exit 1

if exist bfee_docking\third_party\smina\smina del /f /q bfee_docking\third_party\smina\smina
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
