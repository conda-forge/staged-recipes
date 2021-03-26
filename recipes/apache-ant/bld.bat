
set ANT_HOME=%LIBRARY_PREFIX%
call build.bat install
if errorlevel 1 exit 1

:: ensure that ANT_HOME is set correctly
mkdir %PREFIX%\etc\conda\activate.d
echo set "ANT_HOME_CONDA_BACKUP=%%ANT_HOME%%" > "%PREFIX%\etc\conda\activate.d\ant_home.bat"
echo set "ANT_HOME=%%CONDA_PREFIX%%\Library" >> "%PREFIX%\etc\conda\activate.d\ant_home.bat"
mkdir %PREFIX%\etc\conda\deactivate.d
echo set "ANT_HOME=%%ANT_HOME_CONDA_BACKUP%%" > "%PREFIX%\etc\conda\deactivate.d\ant_home.bat
