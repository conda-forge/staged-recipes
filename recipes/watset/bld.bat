CALL mvn -B -Dshade package

MOVE target\watset.jar %LIBRARY_LIB%\ || EXIT 1

ECHO @java -jar %LIBRARY_LIB%\watset.jar %%* > %LIBRARY_BIN%\watset.bat
