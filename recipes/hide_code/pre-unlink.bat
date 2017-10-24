@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" disable hide_code --py --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1
"%PREFIX%\Scripts\jupyter-serverextension.exe" disable hide_code --py --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1
