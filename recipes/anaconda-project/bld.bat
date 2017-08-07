"%PYTHON%" setup.py version_module
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
