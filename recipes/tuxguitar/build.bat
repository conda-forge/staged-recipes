@echo off
setlocal enabledelayedexpansion

set SWT_VERSION=4.37
set MAVEN_LOCAL_REPO=%SRC_DIR%\.m2
if not exist "%MAVEN_LOCAL_REPO%" mkdir "%MAVEN_LOCAL_REPO%"

:: Install platform-specific SWT jar into local Maven repo
call mvn install:install-file ^
    -Dmaven.repo.local="%MAVEN_LOCAL_REPO%" ^
    -DgroupId=org.eclipse.swt ^
    -DartifactId=org.eclipse.swt.win32.win32 ^
    -Dversion=%SWT_VERSION% ^
    -Dpackaging=jar ^
    -Dfile="%SRC_DIR%\swt\swt.jar"
if errorlevel 1 exit /b 1

:: Install the tuxguitar-pom parent POM (src/desktop/pom.xml) itself into the
:: local repo. It is not a module of any reactor we build below (it only has
:: dependencyManagement/pluginManagement, no <modules>), so without this the
:: second, standalone --non-recursive build further down cannot resolve it
:: when reading the effective model of any sibling artifact it depends on.
call mvn -e -f "%SRC_DIR%\src\desktop\pom.xml" install ^
    -Dmaven.repo.local="%MAVEN_LOCAL_REPO%"
if errorlevel 1 exit /b 1

:: Build TuxGuitar (Java only; native WinMM/FluidSynth modules require MinGW and are omitted)
:: -P -platform-linux disables the auto-detected Linux profile in cross-build environments
cd /d "%SRC_DIR%\src\desktop\build-scripts\tuxguitar-windows-swt-x86_64"

:: Rewrite ${project.parent.relativePath} in the pom to an absolute path before Maven
:: runs.  The pom defines project.rootPath=${project.parent.relativePath}, which
:: evaluates to "../../" (trailing slash).  Appending "/../common/resources/" then
:: produces "../..//../common/resources/" — on Windows Java converts slashes to
:: backslashes giving "..\..\\..\", a double-backslash in a relative path that
:: Windows treats as a UNC prefix and rejects with ERROR_INVALID_NAME (code 123).
:: A Python script is used instead of PowerShell to avoid cmd/PS quoting pitfalls.
python "%RECIPE_DIR%\patch_win_pom.py" pom.xml "%SRC_DIR%\src\desktop"
if errorlevel 1 exit /b 1

:: launch4j-maven-plugin 2.1.2 has no working `skip` property, so it cannot be
:: suppressed with -Dlaunch4j.skip=true below -- it would still run during the
:: package phase (before dist/tuxguitar.ico exists) and fail with "Icon doesn't
:: exist.". Rebind its execution to phase "none" so it does not run during this
:: first build; it is rebound to "package" and triggered for real further down,
:: after robocopy fills in the dist directory.
python "%RECIPE_DIR%\patch_win_launch4j.py" pom.xml none
if errorlevel 1 exit /b 1

:: Convenience variables for source directories (used after Maven).
set DESKTOP=%SRC_DIR%\src\desktop
set COMMON=%SRC_DIR%\src\common
set DOCS=%SRC_DIR%\src\docs
set BUILD_SCRIPTS=%SRC_DIR%\src\desktop\build-scripts

:: Skip the maven-antrun-plugin 'copy' execution that copies shared resources
:: into the output directory.  Ant's fileset resolution fails on Windows with
:: ERROR_INVALID_NAME even after patching project.rootPath, because of how the
:: JVM opens paths that contain mixed separators relative to the project basedir.
:: We replicate those copies with robocopy below, after Maven finishes the JARs.
:: The launch4j plugin (tuxguitar.exe) needs dist/tuxguitar.ico to be present
:: first; its execution was rebound to phase "none" above, so it is invoked
:: separately below, after robocopy fills in the dist directory.
::
:: This runs "install" (not just "verify") so that all ~30 reactor modules'
:: SNAPSHOT jars land in the local Maven repo. The second build below is a
:: separate, --non-recursive `mvn` process scoped to just this one module; it
:: can only resolve its sibling-module dependencies (for the dependency-copy
:: executions that populate lib/) from the local repo, not from reactor memory
:: that dies with this process.
call mvn -e clean install ^
    -P -platform-linux ^
    -P platform-windows ^
    -Dmaven.antrun.skip=true ^
    -Dmaven.repo.local="%MAVEN_LOCAL_REPO%"
if errorlevel 1 exit /b 1

:: Replicate what the skipped antrun 'copy' execution would have done.
:: Maven puts the assembled output in target/tuxguitar-<version>-windows-swt-x86_64/.
for /d %%D in ("%CD%\target\tuxguitar-*-windows-swt-x86_64") do set DIST_DIR=%%D
robocopy "%DESKTOP%\TuxGuitar\share"                            "%DIST_DIR%\share"              /E /NFL /NDL /NJH /NJS
robocopy "%COMMON%\resources"                                   "%DIST_DIR%\share"              /E /NFL /NDL /NJH /NJS
robocopy "%DOCS%"                                               "%DIST_DIR%\doc"                /E /NFL /NDL /NJH /NJS
robocopy "%DESKTOP%\TuxGuitar\dist"                             "%DIST_DIR%\dist"               /E /NFL /NDL /NJH /NJS
robocopy "%DESKTOP%\TuxGuitar-resources\resources\soundfont"   "%DIST_DIR%\share\soundfont"    /E /NFL /NDL /NJH /NJS
robocopy "%BUILD_SCRIPTS%\common-resources\common"              "%DIST_DIR%"                    /E /NFL /NDL /NJH /NJS
robocopy "%BUILD_SCRIPTS%\common-resources\common-windows"      "%DIST_DIR%"                    /E /NFL /NDL /NJH /NJS
robocopy "%BUILD_SCRIPTS%\tuxguitar-windows-swt-x86_64\dist"   "%DIST_DIR%\dist"               /E /NFL /NDL /NJH /NJS
:: robocopy exits 0 (no files copied) or 1 (files copied OK); both are success.
:: Exit codes >= 8 indicate errors.
if errorlevel 8 exit /b 1

:: Rebind l4j-clui to "package" now that dist/ is in place. It must be
:: triggered by actually reaching the package phase (not by invoking
:: com.akathist...:launch4j directly) because launch4j-maven-plugin 2.1.2
:: only applies an execution's <configuration> (the <jar>/<icon>/<outfile>
:: paths) when it runs through a bound phase; a direct plugin:goal CLI
:: invocation creates an unconfigured synthetic "default-cli" execution
:: that silently falls back to the plugin's built-in defaults instead,
:: which point at files that don't exist ("Application jar doesn't exist.").
python "%RECIPE_DIR%\patch_win_launch4j.py" pom.xml package
if errorlevel 1 exit /b 1

:: --non-recursive is required: this pom is a reactor aggregator pulling in
:: ~30 other modules (including gervill), and without it Maven runs package
:: (and gervill's own, differently-configured launch4j execution) against
:: every module in that reactor instead of just this one.
call mvn -e --non-recursive package ^
    -P -platform-linux ^
    -P platform-windows ^
    -Dmaven.antrun.skip=true ^
    -Dmaven.repo.local="%MAVEN_LOCAL_REPO%"
if errorlevel 1 exit /b 1

:: Install assembled application to PREFIX
:: Resolve the actual output dir — the pom.xml version may differ from PKG_VERSION
for /d %%D in ("%CD%\target\tuxguitar-*-windows-swt-x86_64") do set DIST_DIR=%%D
if not exist "%PREFIX%\opt\tuxguitar" mkdir "%PREFIX%\opt\tuxguitar"
xcopy /E /I /Y "%DIST_DIR%\" "%PREFIX%\opt\tuxguitar\"
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
(
  echo @echo off
  echo java -cp "%PREFIX%\opt\tuxguitar\lib\*" ^
    -Djava.library.path="%PREFIX%\opt\tuxguitar\lib" ^
    app.tuxguitar.app.TuxGuitar %%*
) > "%PREFIX%\Scripts\tuxguitar.bat"
