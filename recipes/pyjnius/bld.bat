setlocal EnableDelayedExpansion

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    IF NOT EXIST %PREFIX%\etc\conda\%%F.d MKDIR %PREFIX%\etc\conda\%%F.d
    COPY %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)

call %RECIPE_DIR%\activate.bat

SET PYJNIUS_SHARE=%PREFIX%\share\pyjnius
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
nosetests -v
if errorlevel 1 exit 1

:: install and copy
cd ..
pip install --no-deps .
if errorlevel 1 exit 1
copy build\pyjnius.jar "%PYJNIUS_SHARE%"
if errorlevel 1 exit 1
