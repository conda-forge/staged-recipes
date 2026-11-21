@echo off
rem Run the OPSIN command-line program.
rem Extra Java options can be set with JAVA_OPTS.
java %JAVA_OPTS% -jar "%~dp0..\share\opsin\opsin.jar" %*
