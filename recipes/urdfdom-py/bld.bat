%PYTHON% setup.py install --prefix=%LIBRARY_PREFIX% --install-lib=%SP_DIR%
if errorlevel 1 exit 1
