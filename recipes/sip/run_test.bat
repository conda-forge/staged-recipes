cd test

sip -c . -b word.sbf word.sip
if errorlevel 1 exit 1

python configure.py
if errorlevel 1 exit 1

:: This requires running vcvarsall.bat previously,
:: which is not done in the test phase
:: nmake
:: if errorlevel 1 exit 1
