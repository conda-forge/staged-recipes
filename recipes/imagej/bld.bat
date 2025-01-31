@echo on

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if not exist "%PREFIX%\share\imagej" mkdir "%PREFIX%\share\imagej"

mvn --batch-mode --no-transfer-progress clean package -Dmaven.compiler.release=8

copy target\ij-1.x-SNAPSHOT.jar %PREFIX%\share\imagej\ij.jar
copy %RECIPE_DIR%\imagej.bat %PREFIX%\bin\