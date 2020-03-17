@echo off

"%PREFIX%\Scripts\evcxr_jupyter.exe" --uninstall > "%PREFIX%\.messages.txt" 2>&1 && if errorlevel 1 exit 1
