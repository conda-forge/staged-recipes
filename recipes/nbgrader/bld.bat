"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
REM CALL "%PREFIX%\Scripts\jupyter-nbextension" install --sys-prefix --overwrite --py nbgrader || EXIT /B 1
REM IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
REM XXX Placeholder for nbgrader 0.4.x feature release
