setlocal

rem Maven based build doesn't currently work on Linux
CALL mvn clean
CALL mvn process-resources
CALL mvn package -DskipTests

7za x %SRC_DIR%\packaging\target\openrefine-win-%PKG_VERSION%.zip -o%LIBRARY_PREFIX%\opt\
if errorlevel 1 exit 1

ECHO CD %LIBRARY_PREFIX%\opt\openrefine-%PKG_VERSION%\ > %LIBRARY_PREFIX%\bin\refine.bat
ECHO CALL refine.bat %%* >> %LIBRARY_PREFIX%\bin\refine.bat
if errorlevel 1 exit 1