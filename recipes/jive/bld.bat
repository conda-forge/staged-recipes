setlocal EnableDelayedExpansion

call mvn versions:set versions:update-child-modules -DnewVersion=%PKG_VERSION% -DprocessAllModule -DgenerateBackupPoms=false -Prelease

REM Skip the tests because they require to have a tango database running
call mvn install -DskipTests

REM Generate third party license report
call mvn license:aggregate-third-party-report
copy target\site\aggregate-third-party-report.html .

mkdir "%PREFIX%\share\java"
copy target\Jive-%PKG_VERSION%-jar-with-dependencies.jar %PREFIX%\share\java\Jive.jar

mkdir "%SCRIPTS%"
copy "%RECIPE_DIR%\jive.bat" "%SCRIPTS%"
