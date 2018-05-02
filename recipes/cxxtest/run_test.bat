"%CONDA_PREFIX%\Library\bin\cxxtestgen" --version
"%CONDA_PREFIX%\Library\bin\cxxtestgen" --error-printer -o runner.cpp doc/examples/MyTestSuite1.h
if not exist runner.cpp exit 1

IF DEFINED VS140COMNTOOLS (
    "%VS140COMNTOOLS%\vsvars32.bat"
    cl  /I "%CONDA_PREFIX%/Library/include" runner.cpp
    runner.exe
    goto commonexit
)
ECHO "Visual Studio 14.0 Not Found..."

IF DEFINED VS120COMNTOOLS (
    "%VS120COMNTOOLS%\vsvars32.bat"
    cl  /I "%CONDA_PREFIX%/Library/include" runner.cpp
    runner.exe
    goto commonexit
)
ECHO "Visual Studio 12.0 Not Found..."

IF DEFINED VS110COMNTOOLS (
    "%VS110COMNTOOLS%\vsvars32.bat"
    cl  /I "%CONDA_PREFIX%/Library/include" runner.cpp
    runner.exe
    goto commonexit
)
ECHO "Visual Studio 11.0 Not Found..."

IF DEFINED VS100COMNTOOLS (
    "%VS100COMNTOOLS%\vsvars32.bat"
    cl  /I "%CONDA_PREFIX%/Library/include" runner.cpp
    runner.exe
    goto commonexit
)
ECHO "Visual Studio 10.0 Not Found..."
ECHO "WARNING - Could not compile runner.cpp to run tests."

:commonexit
if errorlevel 1 exit 1
