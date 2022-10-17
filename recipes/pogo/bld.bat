setlocal EnableDelayedExpansion

cd fr.esrf.tango.pogo.parent
call mvn versions:set versions:update-child-modules -DnewVersion=%PKG_VERSION% -DprocessAllModule -DgenerateBackupPoms=false -Prelease

REM Skip the tests because they require to have a tango database running
call mvn install -DskipTests

REM Generate third party license report
call mvn license:aggregate-third-party-report
copy target\site\aggregate-third-party-report.html ..

cd ..

mkdir "%PREFIX%\share\java"
copy org.tango.pogo.pogo_gui\target\Pogo-%PKG_VERSION%.jar %PREFIX%\share\java\Pogo.jar

mkdir "%PREFIX%\share\pogo\preferences"
Xcopy %RECIPE_DIR%\preferences "%PREFIX%\share\pogo\preferences\"

mkdir "%SCRIPTS%"
copy "%RECIPE_DIR%\pogo.bat" "%SCRIPTS%"
