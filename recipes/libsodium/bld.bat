@echo off

cd %SRC_DIR%\build-release
CALL !environment! x86_amd64 > nul
ECHO Platform=x64

CALL buildbase builds\msvc\vs2019\libsodium.sln

GOTO end

:buildBase
@ECHO OFF
REM Usage: [buildbase.bat ..\vs2019\mysolution.sln 16]

SETLOCAL enabledelayedexpansion

SET solution=%1
SET log=build_%version%.log
SET tools=Microsoft Visual Studio %version%.0\VC\vcvarsall.bat

SET tools=Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat
SET environment="%programfiles%\!tools!"
IF NOT EXIST !environment! (
SET environment="%programfiles(x86)%\!tools!"
IF NOT EXIST !environment! (
  SET tools=Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat
)
)

SET environment="%programfiles%\!tools!"
IF NOT EXIST !environment! SET environment="%programfiles(x86)%\!tools!"

ECHO Environment: !environment!

IF NOT EXIST !environment! GOTO no_tools

ECHO Building: %solution%

CALL !environment! x86_amd64 > nul
ECHO Platform=x64

ECHO Configuration=DynRelease
msbuild /m /v:n /p:Configuration=DynRelease /p:Platform=x64 %solution% >> %log%
IF errorlevel 1 GOTO error
ECHO Configuration=LtcgDebug

ECHO Complete: %solution%
GOTO end

:error
ECHO *** ERROR, build terminated early, see: %log%
GOTO end

:no_tools
ECHO *** ERROR, build tools not found: !tools!

:end