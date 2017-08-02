


:: Paths assume java-jdk installed by conda
set JCC_JDK=%PREFIX%\Library
set JAVA_HOME=%JCC_JDK%
set PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%;%JCC_JDK%\bin;%JCC_JDK%\lib;%JCC_JDK%\include;%PATH%
set PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%\jre\bin;%JCC_JDK%\bin;%JCC_JDK%\lib;%JCC_JDK%\include;%PATH%
set JDK_HOME=%JCC_JDK%

:: set

"%PYTHON%" test/myrun_test.py
if errorlevel 1 exit 1

:: Add more build steps here, if they are necessary.

:: See
:: http://docs.continuum.io/conda/build.html
:: for a list of environment variables that are set during the build process.
