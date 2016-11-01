"%PYTHON%" setup.py install install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
