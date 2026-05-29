@echo on

set CYCLONEDDS_HOME=%PREFIX%

%PYTHON% -m pip install . -vv --no-build-isolation
if errorlevel 1 exit 1
