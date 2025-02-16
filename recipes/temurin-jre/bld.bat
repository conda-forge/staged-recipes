
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

echo "Moving directories to temurin directory..."

mkdir "%PREFIX%\Library\temurin\bin"
mkdir "%PREFIX%\Library\temurin\conf"
mkdir "%PREFIX%\Library\temurin\legal"
mkdir "%PREFIX%\Library\temurin\lib"

xcopy /s /y /i "bin" "%PREFIX%\Library\temurin\bin\"
xcopy /s /y /i "conf" "%PREFIX%\Library\temurin\conf\"
xcopy /s /y /i "legal" "%PREFIX%\Library\temurin\legal\"
xcopy /s /y /i "lib" "%PREFIX%\Library\temurin\lib\"
xcopy /s /y /i "NOTICE" "%PREFIX%\Library\temurin\"
xcopy /s /y /i  "release" "%PREFIX%\Library\temurin\"

echo "Check Library\teurin dir"
dir "%PREFIX%\Library\temurin"
echo "Check Library\teurin\bin dir"
dir "%PREFIX%\Library\temurin\bin"

echo "Create bin directory if it doesn't exist"
if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"

echo "Create symlink to java.exe"
mklink "%LIBRARY_BIN%\java.exe" "%PREFIX%\Library\temurin\bin\java.exe"
mklink "%LIBRARY_BIN%\java" "%PREFIX%\Library\temurin\bin\java.exe"

echo "Set environment variables"
set "JAVA_HOME=%PREFIX%\Library\temurin"
set "JAVA_LD_LIBRARY_PATH=%PREFIX%\Library\temurin\lib\server"

echo "check java version"
%JAVA_HOME%\bin\java.exe -v

:: Run java -Xshare:dump
echo "Running java -Xshare:dump..."

%JAVA_HOME%\bin\java.exe -Xshare:dump
