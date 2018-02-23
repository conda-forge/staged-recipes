del conda_build.sh

mkdir %LIBRARY_LIB%\chromium
xcopy /s /y %SRC_DIR%\*.* %LIBRARY_LIB%\chromium\

echo %LIBRARY_LIB%\\chromium\\chrome.exe %* > %LIBRARY_BIN%\chrome.cmd
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%% >> %LIBRARY_BIN%\chrome.cmd
