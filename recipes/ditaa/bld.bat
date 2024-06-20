:: Create jar file
copy %RECIPE_DIR%\lein.bat .
CALL lein self-install
CALL lein uberjar

set JAR=ditaa-0.11.0-standalone.jar
copy .\target\%JAR% %LIBRARY_LIB%\ || exit 1

:: create executable
echo @java -ea -jar %LIBRARY_LIB%\%JAR% "$@" %%*> %LIBRARY_BIN%\ditaa.bat
