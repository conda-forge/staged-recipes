@echo on

if not exist %PREFIX%\bin\imagej.bat ( 
    exit /b 1
)

if not exist %PREFIX%\share\imagej\ij.jar (
    exit /b 1
)
