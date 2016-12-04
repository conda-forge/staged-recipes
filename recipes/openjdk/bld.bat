MOVE bin\* %LIBRARY_BIN%
MOVE include\* %LIBRARY_INC%
MOVE jre %LIBRARY_PREFIX%\jre
MOVE lib\* %LIBRARY_LIB%

:: ensure that JAVA_HOME is set correctly
mkdir %PREFIX%\etc\conda\activate.d
echo set "JAVA_HOME_CONDA_BACKUP=%%JAVA_HOME%%" > "%PREFIX%\etc\conda\activate.d\java_home.bat"
echo set "JAVA_HOME=%%CONDA_PREFIX%%\Library" >> "%PREFIX%\etc\conda\activate.d\java_home.bat"
mkdir %PREFIX%\etc\conda\deactivate.d
echo set "JAVA_HOME=%%JAVA_HOME_CONDA_BACKUP%%" > "%PREFIX%\etc\conda\deactivate.d\java_home.bat"
