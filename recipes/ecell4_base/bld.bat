"%PYTHON%" setup.py install
"%PYTHON%" setup.py test
if errorlevel 1 exit 1
