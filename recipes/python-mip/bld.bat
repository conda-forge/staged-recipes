@echo on

set PMIP_CBC_LIBRARY=%PREFIX%
python -m pip install . -vv
if %ERRORLEVEL% NEQ 0 exit 1
