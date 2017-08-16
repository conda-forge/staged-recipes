@echo off

"%PREFIX%\Scripts\jupyter-serverextension.exe" disable jupyterlab --py --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1
