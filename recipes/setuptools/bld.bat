python setup.py install
if errorlevel 1 exit 1

rd /s /q %STDLIB_DIR%\lib2to3
cd %SCRIPTS%
del *.exe
del easy_install-2*
del easy_install-3*
