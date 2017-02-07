@echo off

"%PREFIX%\Scripts\jupyter-nbextension.exe" install egal --py --sys-prefix || exit 1
