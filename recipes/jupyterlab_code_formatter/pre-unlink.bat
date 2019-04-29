@echo off

"%PREFIX%\Scripts\jupyter.exe" serverextension disable jupyterlab_code_formatter --py --sys-prefix > "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
