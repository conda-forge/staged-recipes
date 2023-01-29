sirius.exe --version
if errorlevel 1 exit 1
powershell Invoke-WebRequest -OutFile Kaempferol.ms -Uri https://bio.informatik.uni-jena.de/wp/wp-content/uploads/2021/10/Kaempferol.ms
if errorlevel 1 exit 1
sirius.exe -i %cd%\Kaempferol.ms -o %cd%\test-out sirius
if errorlevel 1 exit 1
::If not exist "test-out\0_Kaempferol_Kaempferol\trees\C15H10O6_[M+H]+.json" (
If not exist "test-out\0_Kaempferol_Kaempferol\trees" (
    echo Framgentation tree test failed!
    exit 1
)