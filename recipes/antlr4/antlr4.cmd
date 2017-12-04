java -Xmx500M -cp "%CONDA_PREFIX%\Library\lib\antlr-4.7-complete.jar;%CLASSPATH%" org.antlr.v4.Tool %*
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
