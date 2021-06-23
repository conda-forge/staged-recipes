@ECHO ON

set MAVEN_OPTS="-Xmx1G"

cd %SRC_DIR%

cmd.exe /c mvn --batch-mode versions:set "-DnewVersion=v%PKG_VERSION%" || goto :error
cmd.exe /c mvn --batch-mode -Dmaven.javadoc.skip=true -Dmaven.source.skip=true package || goto :error

dir %SRC_DIR%\target

if not exist %LIBRARY_LIB% mkdir %LIBRARY_LIB%

copy "%SRC_DIR%\target\plantuml-v%PKG_VERSION%" "%LIBRARY_LIB%\" || goto :error

if not exist %LIBRARY_BIN% mkdir %LIBRARY_BIN%

echo java -Xmx500M -jar %LIBRARY_LIB%\plantuml-v%PKG_VERSION%.jar %%* > %LIBRARY_BIN%\plantuml.cmd
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%% >> %LIBRARY_BIN%\plantuml.cmd

type %LIBRARY_BIN%\plantuml.cmd

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
