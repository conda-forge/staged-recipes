@echo off
1>>"%PREFIX%\.messages.txt" 2>&1 (
  "%PREFIX%\Scripts\jupyter-nbextension.exe" enable nb_conda --py --sys-prefix || EXIT /B 1
  IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

  "%PREFIX%\Scripts\jupyter-serverextension.exe" enable --py nb_conda --sys-prefix || EXIT /B 1
  IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
)
