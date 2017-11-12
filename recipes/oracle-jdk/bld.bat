MOVE bin\* %LIBRARY_BIN%
MOVE include\* %LIBRARY_INC%
MOVE jre %LIBRARY_PREFIX%\jre
MOVE lib\* %LIBRARY_LIB%
MOVE src.zip %LIBRARY_PREFIX%\jre\src.zip

:: ensure that JAVA_HOME is set correctly
mkdir %PREFIX%\etc\conda\activate.d
echo set "JAVA_HOME_CONDA_BACKUP=%%JAVA_HOME%%" > "%PREFIX%\etc\conda\activate.d\java_home.bat"
echo set "JAVA_HOME=%%CONDA_PREFIX%%\Library" >> "%PREFIX%\etc\conda\activate.d\java_home.bat"
mkdir %PREFIX%\etc\conda\deactivate.d
echo set "JAVA_HOME=%%JAVA_HOME_CONDA_BACKUP%%" > "%PREFIX%\etc\conda\deactivate.d\java_home.bat"


###############


:: Setup
set JDK_VER=8u25
if defined NMI_PLATFORM (
  set ON_BATLAB=TRUE
  set URL=http://regtests.fuelcycle.org/jdk-%JDK_VER%-windows-x64.zip
  set JDK=jdk-%JDK_VER%-windows-x64.zip
) else (
  set ON_BATLAB=FALSE
  set URL=http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-%JDK_VER%-windows-x64.exe
  set JDK=jdk-%JDK_VER%-windows-x64.exe
)
echo "On Batlab? %ON_BATLAB%"

set BUILD_CACHE=%RECIPE_DIR%\\..\\build\\cache
if not exist %BUILD_CACHE% (
  mkdir %BUILD_CACHE%
)

:: Download
if not exist %BUILD_CACHE%\\%JDK% (
  curl -L -C - -k -b "oraclelicense=accept-securebackup-cookie" -o %BUILD_CACHE%\\%JDK% %URL%
)
copy %BUILD_CACHE%\\%JDK% %JDK%

:: Install
if "%ON_BATLAB%" == "TRUE" (
  echo "Running on batlab"
  python -c "from zipfile import ZipFile; f = ZipFile(r'%JDK%', 'r'); f.extractall(r'%LIBRARY_PREFIX%'); f.close()"
  dir %LIBRARY_PREFIX%
) else (
  :: This page was pretty helpful http://stackoverflow.com/questions/15292464/how-to-silently-install-java-jdk-into-a-specific-directory-on-windows
  %JDK% /s /log jdk-install.log INSTALLDIR:%LIBRARY_PREFIX%
)
