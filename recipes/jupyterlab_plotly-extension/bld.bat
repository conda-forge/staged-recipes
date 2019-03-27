:: Packs and installs the extension, nodejs extension rebuild is done automatically
:: on jupyterlab startup, when the new extension is detected or was removed
CALL "%PREFIX%\Scripts\jupyter-labextension" install packages\plotly-extension --no-build || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

:: Shared file not to be included.
del /Q "%PREFIX%\share\jupyter\lab\settings\build_config.json" || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
