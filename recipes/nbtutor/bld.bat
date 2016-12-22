CALL npm install || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

CALL npm run build:release || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

(rmdir /s /q "\\?\%cd%\node_modules" 2> NUL) || echo "some issues cleaning up"
"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt

CALL "%PREFIX%\Scripts\jupyter-nbextension" install --sys-prefix --overwrite --py nbtutor || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
