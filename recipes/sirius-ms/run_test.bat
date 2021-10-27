sirius.exe --version

powershell Invoke-WebRequest -OutFile Kaempferol.ms -Uri https://bio.informatik.uni-jena.de/wp/wp-content/uploads/2021/10/Kaempferol.ms

sirius.exe -i %cd%\Kaempferol.ms -o %cd%\test-out sirius

If not exist "test-out\0_Kaempferol_Kaempferol\trees\C15H10O6_[M+H]+.json" (
    echo Framgentation tree test failed!
    Exit /b 1
)