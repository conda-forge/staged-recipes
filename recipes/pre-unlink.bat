@echo off

REM Uninstall BeakerX notebook extension
"%PREFIX%\Scripts\jupyter-nbextension.exe" uninstall beakerx --py --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1

REM Uninstall BeakerX kernel specs
"%PREFIX%\Scripts\jupyter-kernelspec.exe" remove clojure cpp groovy java scala sql --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1
