

"%PYTHON%" setup.py build --includes="%LIBRARY_PREFIX%\include" --libraries="%LIBRARY_PREFIX%\lib:%LIBRARYPREFIX%\bin"
if errorlevel 1 exit 1

"%PYTHON%" setup.py install --prefix="%PREFIX%"
if errorlevel 1 exit 1

