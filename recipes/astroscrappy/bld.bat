:: This is painfully ugly, but might make the build succeed on python 2.7

copy "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\include\stdint.h" "C:\Program Files (x86)\Microsoft Visual Studio 9.0\VC\include"

"%PYTHON%" setup.py install --offline
if errorlevel 1 exit 1

:: Add more build steps here, if they are necessary.

:: See
:: http://docs.continuum.io/conda/build.html
:: for a list of environment variables that are set during the build process.
