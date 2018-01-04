@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" disable jupyter_widget_pivot_table --py --sys-prefix >> "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1