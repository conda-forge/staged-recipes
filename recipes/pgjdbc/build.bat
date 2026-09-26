@echo on
setlocal

set "REPO=%SRC_DIR%\.m2-repository"

call mvn --batch-mode --no-transfer-progress -Dmaven.repo.local="%REPO%" package -Dmaven.test.skip=true -Dmaven.javadoc.skip=true
if errorlevel 1 exit 1

call mvn --batch-mode --no-transfer-progress -Dmaven.repo.local="%REPO%" dependency:unpack-dependencies -DincludeGroupIds=com.ongres.scram,com.ongres.stringprep -Dmdep.useSubDirectoryPerArtifact=true -Dmdep.stripVersion=true -Dmdep.unpack.includes=META-INF/LICENSE -DoutputDirectory=third-party-licenses
if errorlevel 1 exit 1

if not exist "%PREFIX%\share\liquibase\lib" mkdir "%PREFIX%\share\liquibase\lib"
if errorlevel 1 exit 1
copy /Y "target\postgresql-%PKG_VERSION%.jar" "%PREFIX%\share\liquibase\lib\postgresql.jar"
if errorlevel 1 exit 1
