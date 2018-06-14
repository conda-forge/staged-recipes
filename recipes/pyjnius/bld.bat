SET PYJNIUS_SHARE=%PREFIX%\share\pyjnius
SET JDK_HOME=%JAVA_HOME%
mkdir "%PYJNIUS_SHARE%"

call ant all
if errorlevel 1 exit 1
"%PYTHON%" setup.py build_ext --inplace -f
if errorlevel 1 exit 1

:: run tests
cd tests
if errorlevel 1 exit 1
set CLASSPATH=..\build\test-classes;..\build\classes
set PYTHONPATH=..
:: TODO
:: ignore tests for now
:: will need to fix this in the future!
nostests -v
if errorlevel 1 exit 1

:: install and copy
cd ..
pip install --no-deps .
if errorlevel 1 exit 1
copy build\pyjnius.jar "%PYJNIUS_SHARE%"
if errorlevel 1 exit 1

:: ensure that PYJNIUS_JAR is set correctly
mkdir "%PREFIX%\etc\conda\activate.d"
echo SET "PYJNIUS_JAR_BACKUP=%%PYJNIUS_JAR%%" > "%PREFIX%\etc\conda\activate.d\pyjnius.bat"
echo SET "PYJNIUS_JAR=%%CONDA_PREFIX%%\share\pyjnius\pyjnius.jar" >> "%PREFIX%\etc\conda\activate.d\pyjnius.bat"
echo SET "JDK_HOME_BACKUP=%%JDK_HOME%%" >> "%PREFIX%\etc\conda\activate.d\pyjnius.bat"
echo SET "JDK_HOME=%%JAVA_HOME%%" >> "%PREFIX%\etc\conda\activate.d\pyjnius.bat"
mkdir "%PREFIX%\etc\conda\deactivate.d"
echo SET "PYJNIUS_JAR=%%PYJNIUS_JAR_BACKUP%%" > "%PREFIX%\etc\conda\deactivate.d\pyjnius.bat"
echo SET "PYJNIUS_JAR_BACKUP=''" >> "%PREFIX%\etc\conda\deactivate.d\pyjnius.bat"
echo SET "JDK_HOME=%%JDK_HOME_BACKUP%%" >> "%PREFIX%\etc\conda\deactivate.d\pyjnius.bat"
echo SET "JDK_HOME_BACKUP=''" >> "%PREFIX%\etc\conda\deactivate.d\pyjnius.bat"
