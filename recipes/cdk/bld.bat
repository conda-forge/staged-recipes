cmd.exe /c mvn install -DskipTests

@REM Generate third party license report
cmd.exe /c mvn license:aggregate-third-party-report

copy "target\site\aggregate-third-party-report.html" "%RECIPE_DIR%"

mkdir "%PREFIX%\share\java"

copy "bundle\target\cdk-%PKG_VERSION%.jar" "%PREFIX%\share\java\"

mklink "%PREFIX%\share\java\cdk.jar" "cdk-%PKG_VERSION%.jar"
