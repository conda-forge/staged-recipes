mkdir "%LIBRARY_PREFIX%\share\jmol"
unzip jsmol.zip -d "%LIBRARY_PREFIX%\share\jmol"
xcopy /y *.jar "%LIBRARY_PREFIX%\share\jmol"
echo @echo off > "%LIBRARY_PREFIX%\bin\jmol.bat"
echo java -Xmx512m -jar "%LIBRARY_PREFIX%\share\jmol\Jmol.jar" %1 %2 %3 %4 %5 %6 %7 %8 %9 >> "%LIBRARY_PREFIX%\bin\jmol.bat"

