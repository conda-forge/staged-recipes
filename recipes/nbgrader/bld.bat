"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

REM CALL "%PREFIX%\Scripts\jupyter-nbextension" install --sys-prefix --overwrite --py nbgrader || EXIT /B 1
REM XXX Placeholder for next nbgrader release
