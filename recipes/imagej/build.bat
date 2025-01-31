@echo on

if not exist "%LIBRARY_BIN%\bin" (mkdir "%LIBRARY_BIN%")
if not exist "%LIBRARY_PREFIX%\share\imagej" (mkdir "%LIBRARY_PREFIX%\share\imagej")

mvn --batch-mode --no-transfer-progress clean package -Dmaven.compiler.release=8
if %ERRORLEVEL% neq 0 exit 2

copy target\ij-1.x-SNAPSHOT.jar %LIBRARY_PREFIX%\share\imagej\ij.jar
if %ERRORLEVEL% neq 0 exit 3

copy %RECIPE_DIR%\imagej.bat %LIBRARY_BIN%\
if %ERRORLEVEL% neq 0 exit 4