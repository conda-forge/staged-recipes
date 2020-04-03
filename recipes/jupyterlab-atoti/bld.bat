CALL "%PREFIX%\Scripts\jupyter-labextension" install . --no-build || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
