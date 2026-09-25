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
:: The launch4j plugin (tuxguitar.exe) also runs in the package phase and needs
:: dist/tuxguitar.ico to be present first; we skip it here and invoke it separately
:: after the robocopy fills in the dist directory.
call mvn -e clean verify ^
    -P -platform-linux ^
    -P platform-windows ^
    -Dmaven.antrun.skip=true ^
    -Dlaunch4j.skip=true ^
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

:: Build the Windows launcher exe with launch4j now that dist/ is in place.
call mvn -e ^
    com.akathist.maven.plugins.launch4j:launch4j-maven-plugin:2.1.2:launch4j ^
    -P -platform-linux ^
    -P platform-windows ^
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
