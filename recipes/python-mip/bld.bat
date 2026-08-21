@echo on

:: nuke vendored libraries
rmdir /q /s mip/libraries/

set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

python -m pip install . -vv --prefix=%PREFIX%
if %ERRORLEVEL% NEQ 0 exit 1
