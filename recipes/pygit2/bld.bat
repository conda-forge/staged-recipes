set LIBGIT2=%LIBRARY%
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
