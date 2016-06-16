"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

"%PREFIX%\Scripts\jupyter-nbextension" install nb_conda --py --sys-prefix --overwrite
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
