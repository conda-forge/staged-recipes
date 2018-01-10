"%PYTHON%" setup.py install --offline --no-git --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
