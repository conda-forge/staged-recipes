IF NOT "%JAVA_HOME%" == "%PREFIX%\Library" exit 1

pushd test-nio
  javac TestFilePaths.java
  jar cfm TestFilePaths.jar manifest.mf TestFilePaths.class
  java -jar TestFilePaths.jar TestFilePaths.java
  IF ERRORLEVEL 1 exit 1
popd
