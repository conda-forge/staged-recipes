"%PYTHON%" setup.py build --force
"%PYTHON%" -m pip install . -vv"
 if errorlevel 1 exit 1
