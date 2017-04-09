set PATH=%PATH%;C:\mingw-w64\x86_64-6.3.0-posix-seh-rt_v5-rev1\mingw64\bin
if errorlevel 1 exit 1
"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
"%PYTHON%" .\bin\build_model -m mingw32-make all STATIC_FLAG=-static
if errorlevel 1 exit 1
