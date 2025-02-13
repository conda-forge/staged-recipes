
echo on

echo "listing files..."
dir

echo "Creating activate/deactivate directories..."
for %%C in (activate deactivate) do (
    if not exist "%PREFIX%\etc\conda\%%C.d" mkdir "%PREFIX%\etc\conda\%%C.d"
    copy "%RECIPE_DIR%\scripts\%%C.bat" "%PREFIX%\etc\conda\%%C.d\%PKG_NAME%_%%C.bat"
    copy "%RECIPE_DIR%\scripts\%%C-win.sh" "%PREFIX%\etc\conda\%%C.d\%PKG_NAME%_%%C.sh"
)

echo "Creates java home"
if not exist "%PREFIX%\Library" mkdir "%PREFIX%\Library"
if not exist "%PREFIX%\Library\temurin" mkdir "%PREFIX%\Library\temurin"

echo "Moving files to temurin directory..."
xcopy /e /k /h /i bin "%PREFIX%\Library\temurin\"
xcopy /e /k /h /i conf "%PREFIX%\Library\temurin\"
xcopy /e /k /h /i legal "%PREFIX%\Library\temurin\"
xcopy /e /k /h /i lib "%PREFIX%\Library\temurin\"
xcopy /e /k /h /i NOTICE "%PREFIX%\Library\temurin\"
xcopy /e /k /h /i release "%PREFIX%\Library\temurin\"

echo "Create bin directory if it doesn't exist"
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

echo "Create symlink to java.exe"
mklink "%LIBRARY_BIN%\java.exe" "%PREFIX%\Library\temurin\bin\java.exe"
mklink "%LIBRARY_BIN%\java" "%PREFIX%\Library\temurin\bin\java.exe"

echo "Set environment variables"
set "JAVA_HOME=%PREFIX%\opt\temurin"
set "JAVA_LD_LIBRARY_PATH=%JAVA_HOME%\lib\server"

:: Run java -Xshare:dump
%JAVA_HOME%\bin\java.exe -Xshare:dump
