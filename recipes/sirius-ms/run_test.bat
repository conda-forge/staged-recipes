ECHO "### Start TESTING"
ECHO "### [JAVA] Infos about JDK locations"
ECHO "JAVA_HOME = %JAVA_HOME%"
ECHO "JDK_HOME = %JDK_HOME%"

ECHO "### [JAVA] Try run java"
java -version

ECHO "### [JAVA] Try run %JAVA_HOME%"
%JAVA_HOME%/bin/java.exe -version

ECHO "### [DATA] DOWNLOAD TEST DATA"
powershell Invoke-WebRequest -OutFile Kaempferol.ms -Uri https://bio.informatik.uni-jena.de/wp/wp-content/uploads/2021/10/Kaempferol.ms
if errorlevel 1 exit 1

ECHO "### [EXE] RUN SIMPLE VERSION TEST"
sirius --version
if errorlevel 1 exit 1

ECHO "### [EXE] RUN ILP SOLVER TEST"
sirius -i %cd%\Kaempferol.ms -o %cd%\test-out-exe sirius
if errorlevel 1 exit 1

ECHO "### [EXE] CHECK ILP SOLVER TEST"
If not exist "test-out-exe\1_Kaempferol_Kaempferol\trees" (
    echo Framgentation tree test [EXE] failed!
    exit 1
)
