:: copy to library
set JAR=ditaa-0.11.0-standalone.jar
copy .\%JAR% %LIBRARY_LIB%\ || exit 1

:: create executable
echo @java -ea -jar ^%%CONDA_PREFIX^%%\Library\lib\%JAR% %%*> %LIBRARY_BIN%\ditaa.bat
