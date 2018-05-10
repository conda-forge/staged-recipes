SET MYBINDIR="%LIBRARY_PREFIX%\bin"
SET MYINCLUDEDIR="%LIBRARY_PREFIX%\include\cxxtest"
SET MYPYTHONDIR="%LIBRARY_PREFIX%\python"

MKDIR "%MYBINDIR%"
MKDIR "%MYINCLUDEDIR%"
MKDIR "%MYPYTHONDIR%"

XCOPY .\cxxtest\* "%MYINCLUDEDIR%" /E
XCOPY .\bin\cxxtestgen.bat "%MYBINDIR%\" /E
XCOPY "%RECIPE_DIR%\cxxtestgen" "%MYBINDIR%\" /Y

cd .\python
"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1
