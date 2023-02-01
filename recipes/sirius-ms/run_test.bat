setlocal EnableDelayedExpansion

ECHO "### Start TESTING"
ECHO "### [JAVA] Infos about JDK locations"
ECHO "JAVA_HOME = %JAVA_HOME%"
ECHO "JDK_HOME = %JDK_HOME%"

ECHO "### [JAVA] Try run java"
java -version

ECHO "### [JAVA] Try run %JAVA_HOME%"
%JAVA_HOME%/bin/java.exe -version

ECHO "### [EXE] RUN SIMPLE VERSION TEST"
sirius.exe --version
if errorlevel 1 exit 1

ECHO "### [EXE] RUN ILP SOLVER TEST"
sirius.exe -i %RECIPE_DIR%\Kaempferol.ms -o %cd%\test-out-exe sirius
if errorlevel 1 exit 1

ECHO "### [EXE] CHECK ILP SOLVER TEST"
If not exist "%cd%\test-out-exe\1_Kaempferol_Kaempferol\trees" (
    echo Framgentation tree test [EXE] failed!
    exit 1
)
