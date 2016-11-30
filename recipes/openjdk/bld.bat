MOVE bin\* %LIBRARY_BIN%
MOVE include\* %LIBRARY_INC%
MOVE jre %LIBRARY_PREFIX%\jre
MOVE lib\* %LIBRARY_LIB%

:: ensure that JAVA_HOME is set correctly
for %%x in (activate deactivate) do (
    set "dir=%PREFIX%\etc\conda\%%x.d"
    mkdir "!dir!"
    copy "%RECIPE_DIR%\scripts\%%x.bat" "!dir!"
)
