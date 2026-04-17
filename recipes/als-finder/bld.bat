set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%
"%PYTHON%" -m pip install . -vv
if errorlevel 1 exit 1
