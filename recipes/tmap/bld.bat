cd tmap
"%PYTHON%" setup.py install --prefix=%PREFIX%
if errorlevel 1 exit 1
