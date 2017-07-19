@echo off

REM Install BeakerX notebook extension
"%PREFIX%\Scripts\jupyter-nbextension.exe" install beakerx --py --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1

REM Enable BeakerX notebook extension
"%PREFIX%\Scripts\jupyter-nbextension.exe" enable beakerx --py --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1
