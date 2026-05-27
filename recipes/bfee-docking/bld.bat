@echo on

del bfee_docking\third_party\vina\vina
if errorlevel 1 exit 1

del bfee_docking\third_party\smina\smina
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
