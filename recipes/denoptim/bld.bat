cd "%SRC_DIR%"

cmd.exe /c mvn --batch-mode clean || echo ""
cmd.exe /c mvn --batch-mode package || echo ""

copy "%SRC_DIR%\target\denoptim-%PKG_VERSION%-jar-with-dependencies.jar" "%LIBRARY_LIB%\"

md "%SCRIPTS%\"

echo @echo off > "%SCRIPTS%\denoptim.cmd"
echo java -jar "%LIBRARY_LIB%\denoptim-%PKG_VERSION%-jar-with-dependencies.jar" %%* >> "%SCRIPTS%\denoptim.cmd"
echo IF %%ERRORLEVEL%% NEQ 0 EXIT /B %%ERRORLEVEL%% >> "%SCRIPTS%\denoptim.cmd"

echo #!/bin/bash > "%SCRIPTS%\denoptim"
echo java -jar "%LIBRARY_LIB%\denoptim-%PKG_VERSION%-jar-with-dependencies.jar" $@ >> "%SCRIPTS%\denoptim"

