@echo off

:: Budowanie projektu za pomocą Gradle
call gradlew.bat clean build jar createDependenciesJar


:: Tworzenie katalogu docelowego dla Conda
mkdir %PREFIX%\bin

:: Kopiowanie pliku JAR
copy build\libs\*.jar %PREFIX%\bin\

:: Tworzenie skryptu startowego
echo @echo off > %PREFIX%\bin\hpv-kite.bat
echo java -jar %PREFIX%\bin\hpv-kite-1.0.jar %%* >> %PREFIX%\bin\hpv-kite.bat
