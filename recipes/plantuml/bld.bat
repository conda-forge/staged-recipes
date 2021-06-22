set MAVEN_OPTS="-Xmx1G"

cd %SRC_DIR%

cmd.exe /c mvn --batch-mode versions:set "-DnewVersion=v%PKG_VERSION%"
cmd.exe /c mvn --batch-mode -Dmaven.javadoc.skip=true -Dmaven.source.skip=true package

copy "%SRC_DIR%\target\plantuml-v%PKG_VERSION%" "%LIBRARY_LIB%\"

echo java -Xmx500M -jar %LIBRARY_LIB%\\plantuml-v%PKG_VERSION%.jar %%* > %LIBRARY_BIN%\plantuml.cmd
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%% >> %LIBRARY_BIN%\plantuml.cmd
