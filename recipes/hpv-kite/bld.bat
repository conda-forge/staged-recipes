@echo off

:: Budowanie projektu za pomocą Gradle
call gradlew.bat clean build jar createDependenciesJar
if %errorlevel% neq 0 exit /b %errorlevel%

:: Tworzenie katalogu docelowego dla Conda
mkdir %PREFIX%\bin
if %errorlevel% neq 0 exit /b %errorlevel%

:: Kopiowanie pliku JAR
copy build\libs\*.jar %PREFIX%\bin\
if %errorlevel% neq 0 exit /b %errorlevel%

:: Tworzenie skryptu startowego
echo @echo off > %PREFIX%\bin\hpv-kite.bat
if %errorlevel% neq 0 exit /b %errorlevel%
echo java -jar %PREFIX%\bin\hpv-kite-1.0.jar %%* >> %PREFIX%\bin\hpv-kite.bat
if %errorlevel% neq 0 exit /b %errorlevel%
