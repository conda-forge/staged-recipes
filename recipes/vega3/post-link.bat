@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" enable vega3 --py --sys-prefix && if errorlevel 1 exit 1
