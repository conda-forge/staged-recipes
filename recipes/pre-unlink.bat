@echo off

REM Uninstall BeakerX notebook extension
"%PREFIX%\Scripts\jupyter-nbextension.exe" uninstall beakerx --py --sys-prefix > NUL 2>&1 && if errorlevel 1 exit 1

REM Uninstall BeakerX kernel specs
REM python setup.py kernels --disable > /dev/null 2>&1
"%PREFIX%\Scripts\jupyter-kernelspec.exe" remove clojure cpp groovy java scala sql > NUL 2>&1 && if errorlevel 1 exit 1

REM Update kernelspec_class in jupyter_notebook_config.json
REM python setup.py kernelspec_class --disable > NUL 2>&1 && if errorlevel 1 exit 1

REM Restore original custom CSS and assets to notebook custom directory
REM robocopy ./beakerx/custom "${PREFIX}/lib/python3.5/site-packages/notebook/static/custom/" > NUL 2>&1 && if errorlevel 1 exit 1
