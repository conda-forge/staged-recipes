@echo off

:: add dependency-license-report plugin
sed -i "s/^\(\s*\)id 'java'/&\n\1id 'com.github.jk1.dependency-license-report' version 'latest.release'/" build.gradle

:: build package with kite
call gradlew.bat clean build jar createDependenciesJar
if %errorlevel% neq 0 exit /b %errorlevel%
call gradlew generateLicenseReport
if %errorlevel% neq 0 exit /b %errorlevel%

:: create destination folder for conda command and the libraries
mkdir %PREFIX%\bin
if %errorlevel% neq 0 exit /b %errorlevel%
mkdir %PREFIX%\libexec\kite
if %errorlevel% neq 0 exit /b %errorlevel%

:: copy jar files into output dir
copy build\libs\*.jar %PREFIX%\libexec\kite\
if %errorlevel% neq 0 exit /b %errorlevel%

:: create executable scripts
echo @echo off > %PREFIX%\bin\kite.cmd
if %errorlevel% neq 0 exit /b %errorlevel%
echo call %%JAVA_HOME%%\bin\java %%KITE_PARAMS%% -jar %%CONDA_PREFIX%%\libexec\kite\kite-%PKG_VERSION%.jar %* >> %PREFIX%\bin\kite.cmd
if %errorlevel% neq 0 exit /b %errorlevel%

