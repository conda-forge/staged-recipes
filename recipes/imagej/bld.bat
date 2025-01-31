@echo on

if not exist "%PREFIX%\bin" mkdir "%PREFIX%\bin"
if not exist "%PREFIX%\share\imagej" mkdir "%PREFIX%\share\imagej"

mvn clean package -Dmaven.compiler.release=8

copy target\ij-SNAPSHOT.jar %PREFIX%\share\imagej\ij.jar
copy %SRC_DIR%\imagej.bat %PREFIX%\bin\