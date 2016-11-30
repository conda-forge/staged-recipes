MOVE bin\* %LIBRARY_BIN%
MOVE include\* %LIBRARY_INC%
MOVE jre %LIBRARY_PREFIX%\jre
MOVE lib\* %LIBRARY_LIB%

:: ensure that JAVA_HOME is set correctly
for %%action in (activate deactivate) do (
    set "dir=%PREFIX%\etc\conda\%%action.d"
    mkdir "!dir!"
    copy "%RECIPE_DIR%\scripts\%%action.bat" "!dir!"
)
