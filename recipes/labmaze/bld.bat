mkdir localtmpdir

set TMPDIR=%cd%\localtmpdir
set TEMP=%cd%\localtmpdir
set TMP=%cd%\localtmpdir

%PYTHON% -m pip install . -vv --no-deps
if errorlevel 1 exit 1

bazel clean
if errorlevel 1 exit 1

bazel shutdown
if errorlevel 1 exit 1
