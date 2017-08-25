@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" install nbgrader --py --sys-prefix --overwrite >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
"%PREFIX%\Scripts\jupyter-nbextension.exe" enable nbgrader --py --sys-prefix >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
"%PREFIX%\Scripts\jupyter-serverextension.exe" enable nbgrader --py --sys-prefix >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
