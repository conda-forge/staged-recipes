@ECHO ON
cd src\tests\acceptance_tests\javascript

CALL npm install || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

cd ..\..

CALL pytest -k "not language_support" || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
