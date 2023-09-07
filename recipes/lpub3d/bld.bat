
@ECHO OFF &SETLOCAL

Title LPub3D Conda-build Build Script

REM This script uses Conda-build to configure and build LPub3D for Windows.
REM The primary purpose is to setup the 64bit build environment to
REM successfully run the LPub3D AutoBuild.bat which will build and stage
REM the LPub3D distribution build contents (exe, doc and resources ) for release.
REM --
REM  Trevor SANDY <trevor.sandy@gmail.com>
REM  Last Update: September 05, 2023
REM  Copyright (C) 2023 by Trevor SANDY
REM --
REM This script is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

SET "BUILD_ARCH=x86_64"
SET "BUILD_OPT=default"

SET "LP3D_APP=lpub3d"
SET "LP3D_3RD_PARTY=third_party"
SET "LP3D_7ZIP_WIN64=7z.exe"
SET "LP3D_BUILDPKG_PATH=builds\windows\release"
SET "LP3D_3RD_DIST_DIR=lpub3d_windows_3rdparty"

SET "LP3D_QT32_MSVC=Set But Not Used"
SET "LP3D_MSC_VER=1929"
SET "LP3D_QT64_MSVC=%PREFIX%"
SET "LP3D_VSVERSION=%CXX_COMPILER:vs=%"
SET "LP3D_VCSDKVER=%WindowsSDKVer%"
SET "LP3D_VCTOOLSET=%CMAKE_GENERATOR_TOOLSET%"
SET "LP3D_VCVARSALL_VER=-vcvars_ver=14.29"
SET "LP3D_VCVARSALL_DIR=%VSINSTALLDIR%\VC\Auxiliary\Build"
SET "LP3D_VCVARSALL_DIR=%LP3D_VCVARSALL_DIR:\\VC\Aux=\VC\Aux%"

SET "LP3D_BUILD_BASE=%SRC_DIR%"
SET "LP3D_3RD_PARTY_PATH=%LP3D_BUILD_BASE%\%LP3D_3RD_PARTY%"
SET "LP3D_DIST_DIR_PATH=%LP3D_3RD_PARTY_PATH%\windows"
SET "LP3D_LDRAW_DIR_PATH=%LP3D_3RD_PARTY_PATH%\ldraw"

SET "LP3D_CONDA_BUILD=True"
SET "LP3D_CONDA_CONFIG=release"
SET "LP3D_CONDA_JOB=Conda-forge build"
SET "LP3D_CONDA_RUNNER_OS=Windows"
SET "LP3D_CONDA_REPOSITORY=trevorsandy/%LP3D_APP%"
SET "LP3D_CONDA_WORKSPACE=%LP3D_BUILD_BASE%\%LP3D_APP%"
SET "LP3D_BUILD_COMMAND=.\builds\windows\AutoBuild.bat %BUILD_ARCH% -3rd -ins"

FOR /f "delims=" %%i IN ('qmake -query QT_VERSION') DO SET "LP3D_QTVERSION=%%i"

PUSHD %LP3D_BUILD_BASE%

ECHO.
ECHO - Setup work folder links...

IF NOT EXIST "%LP3D_3RD_DIST_DIR%" (
  MKDIR "%LP3D_3RD_DIST_DIR%" >NUL 2>&1
  IF NOT EXIST "%LP3D_3RD_DIST_DIR%" (
    ECHO.
    ECHO - ERROR - Create %LP3D_3RD_DIST_DIR% failed.
    GOTO :ERROR_END
  )
)

IF NOT EXIST "%LP3D_3RD_PARTY%" (
  MKLINK /d %LP3D_3RD_PARTY% %LP3D_3RD_DIST_DIR% >NUL 2>&1
  IF NOT EXIST "%LP3D_3RD_PARTY%" (
    ECHO.
    ECHO - ERROR - Create %LP3D_3RD_PARTY% link failed.
    GOTO :ERROR_END
  )
)

IF NOT EXIST "%LP3D_DIST_DIR_PATH%" (
  PUSHD %LP3D_3RD_PARTY%
  MKLINK /d windows . >NUL 2>&1
  POPD
  IF NOT EXIST "%LP3D_DIST_DIR_PATH%" (
    ECHO.
    ECHO - ERROR - Create %LP3D_DIST_DIR_PATH% link failed.
    GOTO :ERROR_END
  )
)

IF NOT EXIST "%USERPROFILE%\LDraw" (
  IF EXIST "%LP3D_LDRAW_DIR_PATH%" (
    PUSHD %USERPROFILE%
    MKLINK /d LDraw %LP3D_LDRAW_DIR_PATH% >NUL 2>&1
    POPD
  )
  IF NOT EXIST "%USERPROFILE%\LDraw" (
    ECHO.
    ECHO - ERROR - Create %USERPROFILE%\LDraw link failed.
    GOTO :ERROR_END
  ) ELSE (
    SET "CREATED_LDRAW_DIR=True"
  )
)

ECHO.
ECHO - Archive LDraw part libraries...

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\complete.zip" (
  PUSHD %LP3D_3RD_DIST_DIR%
    7z.exe a -y -tzip complete.zip .\ldraw >NUL 2>&1
    IF ERRORLEVEL 1 (GOTO :ERROR_END)
  POPD
)

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\lpub3dldrawunf.zip" (
  PUSHD Parts_Lib\lpub3dldrawunf
    7z.exe a -y -tzip lpub3dldrawunf.zip .\* >NUL 2>&1
    XCOPY lpub3dldrawunf.zip %SRC_DIR%\%LP3D_3RD_DIST_DIR%\ /S /Y >NUL 2>&1
    IF ERRORLEVEL 1 (GOTO :ERROR_END)
  POPD
)

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\tenteparts.zip" (
  PUSHD Parts_Lib\tenteparts
    7z.exe a -y -tzip tenteparts.zip .\ldraw >NUL 2>&1
    XCOPY tenteparts.zip %SRC_DIR%\%LP3D_3RD_DIST_DIR%\ /S /Y >NUL 2>&1
    IF ERRORLEVEL 1 (GOTO :ERROR_END)
  POPD
)

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\vexiqparts.zip" (
  PUSHD Parts_Lib\vexiqparts
    7z.exe a -y -tzip vexiqparts.zip .\ldraw >NUL 2>&1
    XCOPY vexiqparts.zip %SRC_DIR%\%LP3D_3RD_DIST_DIR%\ /S /Y >NUL 2>&1
    IF ERRORLEVEL 1 (GOTO :ERROR_END)
  POPD
)
POPD

PUSHD %LP3D_CONDA_WORKSPACE%
ECHO.
ECHO - Build command: %LP3D_BUILD_COMMAND%
CALL :PATCH_PARSE_DATE_FORMAT
ECHO.
ECHO - Running %LP3D_CONDA_JOB%...
CALL %LP3D_BUILD_COMMAND%
IF NOT ERRORLEVEL 0 GOTO :ERROR_END
CALL :GEN_MENU_SHORTCUT_JSON
CALL :CLEANUP_LDRAW_DIR
POPD
ECHO.
ECHO - %LP3D_CONDA_JOB% finished.
ENDLOCAL
EXIT /b 0

:PATCH_PARSE_DATE_FORMAT
SET LP3D_FILE="gitversion.pri"
SET /a LP3D_LINE_TO_REPLACE=160
SET "LP3D_REPLACEMENT=if (conda_ci) {"
(FOR /f "tokens=1*delims=:" %%a IN ('findstr /n "^" "%LP3D_FILE%"') DO (
  SET "LP3D_LINE=%%b"
  SETLOCAL ENABLEDELAYEDEXPANSION
  IF %%a EQU %LP3D_LINE_TO_REPLACE% (
    SET "LP3D_LINE=%LP3D_REPLACEMENT%"
  )
  ECHO(!LP3D_LINE!
  ENDLOCAL
))>"%LP3D_FILE%.new"
MOVE /Y %LP3D_FILE%.new %LP3D_FILE% | findstr /i /v /r /c:"moved\>"
ECHO.
IF ERRORLEVEL 0 (
  ECHO - Patched parse date format.
) ELSE (
  ECHO - Failed to patch parse date format.
  GOTO :ERROR_END
)
EXIT /b

:GEN_MENU_SHORTCUT_JSON
IF NOT EXIST "%PREFIX%\Menu" (
  MKDIR "%PREFIX%\Menu" >NUL 2>&1
  IF ERRORLEVEL 1 (
    ECHO - ERROR - Create %PREFIX%\Menu folder failed.
    EXIT /b
  )
)
:: using menuinst v1 until v2 is released
ECHO.
ECHO - Create %PKG_NAME%_menu.json...
COPY /Y "%RECIPE_DIR%\lpub3d.ico" "%PREFIX%\Menu\LPub3D.ico" >NUL 2>&1
SET "GEN_SHORTCUT=%PREFIX%\Menu\%PKG_NAME%_menu.json"
SET genShortcut=%GEN_SHORTCUT% ECHO
 >%genShortcut% {
>>%genShortcut%    "menu_name":"LPub3D (64-bit)",
>>%genShortcut%    "menu_items":[
>>%genShortcut%       {
>>%genShortcut%          "system":"${PREFIX}\\Library\\bin\\LPub3D.exe",
>>%genShortcut%          "name":"LPub3D (%PKG_VERSION%)",
>>%genShortcut%          "workdir":"${PREFIX}\\Library\\bin",
>>%genShortcut%          "icon":"${MENU_DIR}\\LPub3D.ico",
>>%genShortcut%          "desktop":false,
>>%genShortcut%          "quicklaunch":false
>>%genShortcut%       }
>>%genShortcut%    ]
>>%genShortcut% }
EXIT /b

:CLEANUP_LDRAW_DIR
IF "%CREATED_LDRAW_DIR%" EQU "True" (
  PUSHD %USERPROFILE%
  RMDIR /S /Q LDraw >NUL 2>&1
  POPD
)
EXIT /b

:ERROR_END
CALL :CLEANUP_LDRAW_DIR
POPD
ECHO.
ECHO - %LP3D_CONDA_JOB% FAILED!
ECHO.
IF EXIST "%LP3D_BUILD_LOG%" TYPE "%LP3D_BUILD_LOG%"
ECHO.
ENDLOCAL
EXIT /b 1
