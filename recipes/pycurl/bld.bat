%PYTHON% setup.py install --curl-dir=%LIBRARY_PREFIX% --use-libcurl-dll
if errorlevel 1 exit 1

rd /s /q %PREFIX%\Doc
