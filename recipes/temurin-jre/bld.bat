
echo on

echo "listing files..."
dir

echo "Creating activate/deactivate directories..."
for %%C in (activate deactivate) do (
    if not exist "%PREFIX%\etc\conda\%%C.d" mkdir "%PREFIX%\etc\conda\%%C.d"
    copy "%RECIPE_DIR%\scripts\%%C.bat" "%PREFIX%\etc\conda\%%C.d\%PKG_NAME%_%%C.bat"
)
echo "Creates java home"
if not exist "%PREFIX%\opt" mkdir "%PREFIX%\opt"
if not exist "%PREFIX%\opt\temurin" mkdir "%PREFIX%\opt\temurin"

echo "Moving files to temurin directory..."
xcopy /e /k /h /i bin "%PREFIX%\opt\temurin\"
xcopy /e /k /h /i conf "%PREFIX%\opt\temurin\"
xcopy /e /k /h /i legal "%PREFIX%\opt\temurin\"
xcopy /e /k /h /i lib "%PREFIX%\opt\temurin\"
xcopy /e /k /h /i NOTICE "%PREFIX%\opt\temurin\"
xcopy /e /k /h /i release "%PREFIX%\opt\temurin\"

echo "Create bin directory if it doesn't exist"
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

echo "Create symlink to java.exe"
mklink "%PREFIX%\bin\java.exe" "%PREFIX%\opt\temurin\bin\java.exe"

echo "Set environment variables"
set "JAVA_HOME=%PREFIX%\opt\temurin"
set "PATH=%PREFIX%\bin;%PATH%"
set "JAVA_LD_LIBRARY_PATH=%JAVA_HOME%\lib\server"

:: Run java -Xshare:dump
java.exe -Xshare:dump
