ECHO "### Start TESTING"

ECHO "### DOWNLOAD TEST DATA"
powershell Invoke-WebRequest -OutFile Kaempferol.ms -Uri https://bio.informatik.uni-jena.de/wp/wp-content/uploads/2021/10/Kaempferol.ms
if errorlevel 1 exit 1



ECHO "### [BAT] RUN SIMPLE VERSION TEST"
sirius.bat --version
if errorlevel 1 exit 1

ECHO "### [BAT]  RUN ILP SOLVER TEST
sirius.bat -i %cd%\Kaempferol.ms -o %cd%\test-out-bat sirius
if errorlevel 1 exit 1

ECHO "### [BAT] CHECK ILP SOLVER TEST
If not exist "test-out-bat\1_Kaempferol_Kaempferol\trees" (
    echo Framgentation tree test [EXE] failed!
    exit 1
)


ECHO "### [EXE] RUN SIMPLE VERSION TEST"
sirius.exe --version
if errorlevel 1 exit 1

ECHO "### [EXE] RUN ILP SOLVER TEST
sirius.exe -i %cd%\Kaempferol.ms -o %cd%\test-out-exe sirius
if errorlevel 1 exit 1

ECHO "### [EXE] CHECK ILP SOLVER TEST
If not exist "test-out-exe\1_Kaempferol_Kaempferol\trees" (
    echo Framgentation tree test [EXE] failed!
    exit 1
)