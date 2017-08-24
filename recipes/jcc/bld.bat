
echo on
echo "Starting build script... PHY"

:: Paths assume java-jdk installed by conda
set JCC_JDK=%JAVA_HOME%

set PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%;%JCC_JDK%\bin;%JCC_JDK%\lib;%JCC_JDK%\include;%JCC_JDK%\include\win32;%PATH%
set PATH=%JCC_JDK%\jre\bin;%PATH%

set JCC_INCLUDES=%JCC_JDK%\include\win32;%JCC_JDK%\include
set JCC_LFLAGS=/DLL;/LIBPATH:%JCC_JDK%\lib;Ws2_32.lib;jvm.lib
set JDK_HOME=%JCC_JDK%

set

::cd jcc
"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1

:: Add more build steps here, if they are necessary.

:: See
:: http://docs.continuum.io/conda/build.html
:: for a list of environment variables that are set during the build process.
