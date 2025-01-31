@echo on

if not exist "%PREFIX%\Library\bin" (mkdir "%PREFIX%\Library\bin")
if not exist "%PREFIX%\Library\share\imagej" (mkdir "%PREFIX%\Library\share\imagej")

call mvn --batch-mode --no-transfer-progress clean package -Dmaven.compiler.release=8
if %ERRORLEVEL% neq 0 (echo "==== PROBLEM" && exit 2)

copy target\ij-1.x-SNAPSHOT.jar "%PREFIX%\Library\share\imagej\ij.jar"
if %ERRORLEVEL% neq 0 exit 3

copy %RECIPE_DIR%\imagej.bat "%PREFIX%\Library\bin"
if %ERRORLEVEL% neq 0 exit 4