%PYTHON% setup.py install --system-zstd --single-version-externally-managed --record=record.txt -DUSE_SYSTEM_BLOSC2:BOOL=YES
if errorlevel 1 exit 1
