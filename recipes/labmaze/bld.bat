%PYTHON% -m pip install . -vv --no-deps
if errorlevel 1 exit 1

bazel shutdown
if errorlevel 1 exit 1
