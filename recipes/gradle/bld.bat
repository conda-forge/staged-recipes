rem output commands
echo on

rem set destination path and modify PATH variable
set DEST=%LIBRARY_PREFIX%
set PATH=%PATH%;%DEST%\bin

rem build gradle
mkdir build
gradlew.bat installAll -Pgradle_installPath=build\
xcopy build\ %DEST% /O /X /E /H /K
