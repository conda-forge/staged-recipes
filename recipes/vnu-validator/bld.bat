@ECHO ON

cd "%SRC_DIR%"

if not exist "%LIBRARY_LIB%" mkdir "%LIBRARY_LIB%"

copy build\dist\vnu.jar "%LIBRARY_LIB%\vnu.jar" || goto :error

if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"

echo java -jar %LIBRARY_LIB%\vnu.jar %%*                 > "%LIBRARY_BIN%\vnu.cmd"
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%%     >> "%LIBRARY_BIN%\vnu.cmd"

type %LIBRARY_BIN%\vnu.cmd

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
