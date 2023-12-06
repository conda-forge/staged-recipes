mkdir "%PREFIX%"\lib
mkdir "%PREFIX%"\lib\java
mkdir "%PREFIX%"\lib\java\PanoplyJ
mkdir "%SCRIPTS%"\
xcopy "%SRC_DIR%\*" "%PREFIX%\lib\java\PanoplyJ\" /s /e

echo java -Xms512m -Xmx1600m %JAVA_OPTS% -jar %PREFIX%\lib\java\PanoplyJ\jars\Panoply.jar%%* > "%SCRIPTS%\panoply.bat"
  