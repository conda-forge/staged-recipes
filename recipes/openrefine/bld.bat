setlocal

rem Maven based build doesn't currently work on Linux
CALL mvn clean
CALL mvn process-resources
CALL mvn package -DskipTests

CD %SRC_DIR%\packaging\target\
7z e openrefine-win-%PKG_VERSION%.zip
if errorlevel 1 exit 1

ROBOCOPY openrefine-%PKG_VERSION% %LIBRARY_PREFIX%\opt\openrefine /E
ECHO CD %LIBRARY_PREFIX%\opt\openrefine\ > %LIBRARY_PREFIX%\bin\refine.bat
ECHO CALL refine.bat %%* >> %LIBRARY_PREFIX%\bin\refine.bat
if errorlevel 1 exit 1