echo ****************************
echo PYTHON %PYTHON% BUILD STARTED
echo ****************************

COPY cantera.conf cantera.conf.bak
DEL /F cantera.conf
FINDSTR /V "python_package" cantera.conf.bak > cantera.conf
DEL /F cantera.conf.bak

ECHO python_package='full' >> cantera.conf
SET "ESC_PYTHON=%PYTHON:\=/%"
ECHO python_cmd="%ESC_PYTHON%" >> cantera.conf

CALL scons build
IF ERRORLEVEL 1 EXIT 1

echo ****************************
echo PYTHON %PYTHON% BUILD COMPLETED SUCCESSFULLY
echo ****************************

cd interfaces/cython
"%PYTHON%" setup.py build --build-lib=../../build/python install
IF ERRORLEVEL 1 EXIT 1
