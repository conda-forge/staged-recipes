@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" disable gmaps --py --sys-prefix && if errorlevel 1 exit 1