set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
