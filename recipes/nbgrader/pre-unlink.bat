@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" disable nbgrader --py --sys-prefix >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
"%PREFIX%\Scripts\jupyter-nbextension.exe" uninstall nbgrader --py --sys-prefix >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
"%PREFIX%\Scripts\jupyter-serverextension.exe" disable nbgrader --py --sys-prefix >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
