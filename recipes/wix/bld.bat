REM Share VC version
SET VSINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio 14.0
SET VCINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC
SET DevEnvDir=%VSINSTALLDIR%\Common7\IDE

SET WindowsSdkDir=

REM Call with help will trigger clean-up
CALL "%WIN_SDK_ROOT%\%WINDOWS_SDK_VERSION%\Bin\SetEnv.cmd" /?
SET CURRENT_CPU=
SET TARGET_CPU=
SET WINDOWS_SDK_VERSION=
SET MSSdk=1

SET VS_VERSION=
SET VS_MAJOR=
SET VS_YEAR=

SET INCLUDE=
SET LIB=
SET LIBPATH=
SET APPVER=
SET CL=

SET FrameworkDir=
SET FrameworkVersion=
SET PlatformToolset=
SET sdkdir=
SET ToolsVersion=
SET WindowsSDKVersionOverride=
SET TARGET_PLATFORM=

@if exist "%ProgramFiles%\HTML Help Workshop" SET PATH=%ProgramFiles%\HTML Help Workshop;%PATH%
@if exist "%ProgramFiles(x86)%\HTML Help Workshop" SET PATH=%ProgramFiles(x86)%\HTML Help Workshop;%PATH%

SET Platform=
SET CommandPromptType=

SET CONFIGURATION=Release

REM Debug: Print out all env vars
SET

REM Skip strong name key signing
"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" tools/OneTimeWixBuildInitialization.proj
if %ERRORLEVEL% NEQ 0 exit 1
REM Build
"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe"
ECHO "Build finished: %ERRORLEVEL%"
if %ERRORLEVEL% NEQ 0 exit 1

REM Run test in build environment:
CALL test/test.bat
ECHO "Test finished: %ERRORLEVEL%"
if %ERRORLEVEL% NEQ 0 exit 1

REM Run packaging project
"C:/Program Files (x86)/MSBuild/14.0/Bin/MSBuild.exe" src/Setup/Zip/binaries.zipproj
ECHO "Packaging finished: %ERRORLEVEL%"
if %ERRORLEVEL% NEQ 0 exit 1

7z x build\ship\x86\wix*-binaries.zip -o"%PREFIX%\wix"
if %ERRORLEVEL% NEQ 0 exit 1

exit 0
