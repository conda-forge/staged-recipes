CALL mvn -B license:aggregate-third-party-report

MOVE target\site\aggregate-third-party-report.html . || EXIT 1

CALL mvn -B -Dshade package

MOVE target\watset.jar %LIBRARY_LIB%\ || EXIT 1

ECHO @java -jar %LIBRARY_LIB%\watset.jar %%* > %LIBRARY_BIN%\watset.bat
