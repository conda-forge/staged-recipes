%PYTHON% setup.py install --prefix=%LIBRARY_PREFIX% --install-lib=%SP_DIR% --single-version-externally-managed --record ./installed_files
if errorlevel 1 exit 1
