"%PYTHON%" -m pip install -vv --no-deps .\datalayer-core
"%PYTHON%" -m pip install -vv --no-deps .\datalayer-ui
"%PYTHON%" -m pip install -vv --no-deps .\jupyter-iam
"%PYTHON%" -m pip install -vv --no-deps .\jupyter-kernels
"%PYTHON%" -m pip install -vv --no-deps .\datalayer
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
