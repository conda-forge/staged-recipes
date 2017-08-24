:: Paths assume openjdk installed by conda
set JCC_JDK=%JAVA_HOME
set PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%;%JCC_JDK%\bin;%JCC_JDK%\lib;%JCC_JDK%\include;%PATH%
set PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%\jre\bin;%JCC_JDK%\bin;%JCC_JDK%\lib;%JCC_JDK%\include;%PATH%
set JDK_HOME=%JCC_JDK%

"%PYTHON%" test/myrun_test.py
if errorlevel 1 exit 1
