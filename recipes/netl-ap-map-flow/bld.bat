"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
"%PYTHON%" .\bin\build_model -m mingw32-make.exe all STATIC_FLAG=-static
if errorlevel 1 exit 1
