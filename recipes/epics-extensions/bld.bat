:: install epics-extensions into EPICS_BASE

:: create target directory
mkdir %EPICS_BASE%\extensions
if errorlevel 1 exit 1

:: copy extensions configure directory across
xcopy /e /i /k /s /y %SRC_DIR%\configure %EPICS_BASE%\extensions\configure
if errorlevel 1 exit 1
