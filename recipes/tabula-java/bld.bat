set MAVEN_OPTS="-Xmx1G"

cmd.exe /c mvn clean compile assembly:single || echo ""

copy "%SRC_DIR%\target\tabula-%PKG_VERSION%-jar-with-dependencies.jar" "%LIBRARY_LIB%\tabula.jar"

echo java -Xmx500M -jar %LIBRARY_LIB%\\tabula.jar %* > %LIBRARY_BIN%\tabula.cmd
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%% >> %LIBRARY_BIN%\tabula.cmd
