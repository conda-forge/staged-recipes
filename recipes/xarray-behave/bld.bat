# We need to turn pip index back on because Anaconda turns
# it off for some reason.
set PIP_NO_INDEX=False
set PIP_NO_DEPENDENCIES=False
set PIP_IGNORE_INSTALLED=False

"%PYTHON%" -m pip install simpleaudio -vv --no-dependencies
"%PYTHON%" -m pip install pkgutil_resolve_name -vv --no-dependencies
"%PYTHON%" -m pip install xarray-behave[gui] -vv --no-dependencies
if errorlevel 1 exit 1
