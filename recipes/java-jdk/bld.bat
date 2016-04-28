:: Setup
set JDK_VER=8u25
set URL=http://download.oracle.com/otn-pub/java/jdk/8u25-b17/jdk-%JDK_VER%-windows-x64.exe
set JDK=jdk-%JDK_VER%-windows-x64.exe

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
:: This page was pretty helpful http://stackoverflow.com/questions/15292464/how-to-silently-install-java-jdk-into-a-specific-directory-on-windows
%JDK% /s /log jdk-install.log INSTALLDIR:%LIBRARY_PREFIX%
