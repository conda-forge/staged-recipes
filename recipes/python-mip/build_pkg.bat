@echo on

:: nuke vendored libraries
rmdir /q /s mip/libraries/

set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%
set PMIP_CBC_LIBRARY=%PREFIX%
python -m pip install . -vv
if %ERRORLEVEL% NEQ 0 exit 1
