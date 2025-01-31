@echo on

if not exist "%PREFIX%\bin" (mkdir "%PREFIX%\bin")
if not exist "%PREFIX%\share\imagej" (mkdir "%PREFIX%\share\imagej")

mvn --no-transfer-progress clean package -Dmaven.compiler.release=8
if %ERRORLEVEL% neq 0 exit 2

copy target\ij-1.x-SNAPSHOT.jar %PREFIX%\share\imagej\ij.jar
if %ERRORLEVEL% neq 0 exit 3

copy %RECIPE_DIR%\imagej.bat %PREFIX%\bin\
if %ERRORLEVEL% neq 0 exit 4