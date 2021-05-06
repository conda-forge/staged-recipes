
"%PYTHON%" -c "cmd=\"with open('setup.py', 'r') as f:\n  lines= f.readlines()\nwith open('setup.py', 'w') as f:\n  for line in lines:\n    f.write(line.replace('PTHREAD\\': 1', 'PTHREAD\\': 0'))\n\"; exec(cmd)"

"%PYTHON%" setup.py build --includes="%LIBRARY_PREFIX%\include" --libraries="%LIBRARY_PREFIX%\lib:%LIBRARYPREFIX%\bin"
if errorlevel 1 exit 1

"%PYTHON%" setup.py install --prefix="%PREFIX%"
if errorlevel 1 exit 1

