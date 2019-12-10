set "CMAKE_GENERATOR=NMake Makefiles"
"%PYTHON%" -m pip install -vv .
if errorlevel 1 exit 1
