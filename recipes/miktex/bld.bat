

7za x miktex-portable-%PKG_VERSION%.exe -o%LIBRARY_PREFIX%\miktex
if errorlevel 1 exit 1


rem SCRIPTS dir should already be created by 7za install
mkdir "%SCRIPTS%"
if errorlevel 1 exit 1

rem latex tools must be run from miktex tree
for %%f in ("%LIBRARY_PREFIX%\miktex\miktex\bin\*.exe") do (
	echo @%%~dp0\..\Library\miktex\miktex\bin\%%~nf %%* >> "%SCRIPTS%\%%~nf.bat"
)
if errorlevel 1 exit 1

