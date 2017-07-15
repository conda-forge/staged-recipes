@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" uninstall full_width --py --sys-prefix >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1