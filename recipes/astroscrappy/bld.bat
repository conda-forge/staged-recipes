:: This is painfully ugly, but might make the build succeed on python 2.7

copy "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\include\stdint.h" "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\include"

"%PYTHON%" setup.py install --offline  --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
