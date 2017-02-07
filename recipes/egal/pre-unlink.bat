@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" uninstall egal --py --sys-prefix || exit 1
