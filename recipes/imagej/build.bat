@echo on

echo "PREFIX: %PREFIX%"
echo "CONDA_PREFIX: %CONDA_PREFIX%"
echo "LIBRARY_PREFIX: %LIBRARY_PREFIX%"
echo "LIBRARY_BIN: %LIBRARY_BIN%"


call %CONDA_PREFIX%\Scripts\activate.bat

echo "--- cd  LIBRARY_BIN"
cd  %LIBRARY_BIN%
dir

echo "--- cd  PREFIX"
cd  %PREFIX%
dir

echo "--- cd  PREFIX\bin"
cd  %PREFIX%\bin
dir
 
if not exist "%PREFIX%\bin" (mkdir "%PREFIX%\bin")
if not exist "%PREFIX%\share\imagej" (mkdir "%PREFIX%\share\imagej")

echo "--- cd  PREFIX\bin 2"
cd  %PREFIX%\bin
dir

echo "--- cd Share"
cd %PREFIX%\share%
dir

cd %SRC_DIR%

mvn --batch-mode --no-transfer-progress clean package -Dmaven.compiler.release=8
if %ERRORLEVEL% neq 0 (echo "==== PROBLEM" && exit 2)

copy target\ij-1.x-SNAPSHOT.jar %PREFIX%\share\imagej\ij.jar
if %ERRORLEVEL% neq 0 exit 3

copy %RECIPE_DIR%\imagej.bat %PREFIX%\bin\
if %ERRORLEVEL% neq 0 exit 4