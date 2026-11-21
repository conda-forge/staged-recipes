@echo off
rem Run the centres command-line program (CIP stereo labelling).
rem Extra Java options can be set with JAVA_OPTS.
java %JAVA_OPTS% -jar "%~dp0..\share\centres\centres.jar" %*
