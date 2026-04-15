@echo on

REM Step 1: Build the Java JAR with Maven
cd "%SRC_DIR%\java"
call mvn package -DskipTests
if errorlevel 1 exit 1

REM Step 2: Pre-stage required files so hatchling's build hook skips the
REM         relative-path glob (../../java/...) which is unreliable on Windows
set PKGDIR=%SRC_DIR%\python\opendataloader-pdf
set SRCPKG=%PKGDIR%\src\opendataloader_pdf

mkdir "%SRCPKG%\jar" 2>nul
for %%f in ("%SRC_DIR%\java\opendataloader-pdf-cli\target\opendataloader-pdf-cli-*.jar") do (
    copy "%%f" "%SRCPKG%\jar\opendataloader-pdf-cli.jar"
)
if errorlevel 1 exit 1

copy "%SRC_DIR%\LICENSE" "%SRCPKG%\LICENSE"
if errorlevel 1 exit 1
copy "%SRC_DIR%\NOTICE" "%SRCPKG%\NOTICE"
if errorlevel 1 exit 1
copy "%SRC_DIR%\README.md" "%PKGDIR%\README.md"
if errorlevel 1 exit 1
xcopy /E /I /Y "%SRC_DIR%\THIRD_PARTY" "%SRCPKG%\THIRD_PARTY\"
if errorlevel 1 exit 1

REM Step 3: Install the Python wrapper
cd "%PKGDIR%"
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
