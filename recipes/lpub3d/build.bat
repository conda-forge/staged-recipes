
@ECHO OFF &SETLOCAL

Title LPub3D Conda Build Script

REM This script uses Rattler-build for Conda-forge to configure and build LPub3D
REM the Conda LPub3D application for Windows.
REM --
REM The primary purpose is to setup the 64bit build environment to
REM successfully run the LPub3D AutoBuild.bat which will build and stage
REM the LPub3D distribution build contents (exe, doc and resources ) for release.
REM --
REM  Trevor SANDY <trevor.sandy@gmail.com>
REM  Last Update: March  22, 2025
REM  Copyright (C) 2023 - 2025 by Trevor SANDY
REM --
REM This script is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

REM To ensure MMDDYYYY date format, set BUILD_OPT 'local' when
REM building locally otherwise 'default' or 'verify' accordingly.

SET "BUILD_OPT=default"
SET "BUILD_ARCH=x86_64"

SET "LP3D_APP=lpub3d"
SET "LP3D_3RD_PARTY=third_party"
SET "LP3D_7ZIP_WIN64=7z.exe"
SET "LP3D_BUILDPKG_PATH=builds\windows\release"
SET "LP3D_3RD_DIST_DIR=lpub3d_windows_3rdparty"

SET "LP3D_QT32_MSVC=Set But Not Used"
SET "LP3D_MSC_VER=1942"
SET "LP3D_QT64_MSVC=%PREFIX%"
SET "LP3D_VSVERSION=%CXX_COMPILER:vs=%"
SET "LP3D_VCSDKVER=%WindowsSDKVer%"
SET "LP3D_VCTOOLSET=%CMAKE_GENERATOR_TOOLSET%"
SET "LP3D_VCVARSALL_VER=-vcvars_ver=14.42"
SET "LP3D_VCVARSALL_DIR=%VSINSTALLDIR%\VC\Auxiliary\Build"
SET "LP3D_VCVARSALL_DIR=%LP3D_VCVARSALL_DIR:\\VC\Aux=\VC\Aux%"

SET "LP3D_BUILD_BASE=%SRC_DIR%"
SET "LP3D_3RD_PARTY_PATH=%LP3D_BUILD_BASE%\%LP3D_3RD_PARTY%"
SET "LP3D_DIST_DIR_PATH=%LP3D_3RD_PARTY_PATH%\windows"
SET "LP3D_LDRAW_DIR_PATH=%LP3D_3RD_PARTY_PATH%\ldraw"
SET "LP3D_VER_INFO_NAME=version.info"
SET "LP3D_VER_INFO_PATH=builds\utilities"
SET "LP3D_VER_INFO_FILE=%LP3D_VER_INFO_PATH%\%LP3D_VER_INFO_NAME%"

SET "LP3D_CONDA_BUILD=True"
SET "LP3D_CONDA_CONFIG=release"
SET "LP3D_CONDA_JOB=Conda-forge Rattler-build"
SET "LP3D_CONDA_RUNNER_OS=Windows"
SET "LP3D_CONDA_REPOSITORY=trevorsandy/%LP3D_APP%"
SET "LP3D_CONDA_WORKSPACE=%LP3D_BUILD_BASE%\%LP3D_APP%"
SET "LP3D_BUILD_SCRIPT=builds\windows\AutoBuild.bat
SET "LP3D_BUILD_COMMAND=.\%LP3D_BUILD_SCRIPT% %BUILD_ARCH% -3rd -ins"

FOR /f "delims=" %%i IN ('qmake -query QT_VERSION') DO SET "LP3D_QTVERSION=%%i"

PUSHD %LP3D_BUILD_BASE%

ECHO - Stage LDraw part libraries...

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\complete.zip" (
  ECHO - ERROR - Parts library complete.zip was not found.
  GOTO :ERROR_END
) ELSE (
  IF NOT EXIST "%LP3D_3RD_DIST_DIR%\LDraw" (
    PUSHD %LP3D_3RD_DIST_DIR%
      7z.exe x -y complete.zip >NUL 2>&1
    POPD
    IF NOT EXIST "%LP3D_3RD_DIST_DIR%\LDraw\parts" (
      ECHO - WARNING - Parts library complete.zip was not extracted.
    )
  )
)

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\lpub3dldrawunf.zip" (
  ECHO - ERROR - Parts library lpub3dldrawunf.zip was not found.
  GOTO :ERROR_END
)

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\tenteparts.zip" (
  ECHO - ERROR - Parts library tenteparts.zip was not found.
  GOTO :ERROR_END
)

IF NOT EXIST "%LP3D_3RD_DIST_DIR%\vexiqparts.zip" (
  ECHO - ERROR - Parts library vexiqparts.zip was not found.
  GOTO :ERROR_END
)

ECHO - Setup work folder links...

IF NOT EXIST "%LP3D_3RD_PARTY%" (
  MKLINK /d %LP3D_3RD_PARTY% %LP3D_3RD_DIST_DIR% >NUL 2>&1
  IF NOT EXIST "%LP3D_3RD_PARTY%" (
    ECHO - ERROR - Create %LP3D_3RD_PARTY% link failed.
    GOTO :ERROR_END
  )
)

IF NOT EXIST "%LP3D_DIST_DIR_PATH%" (
  PUSHD %LP3D_3RD_PARTY%
  MKLINK /d windows . >NUL 2>&1
  POPD
  IF NOT EXIST "%LP3D_DIST_DIR_PATH%" (
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
    ECHO - ERROR - Create %USERPROFILE%\LDraw link failed.
    GOTO :ERROR_END
  ) ELSE (
    SET "CREATED_LDRAW_DIR=True"
  )
)

POPD

PUSHD %LP3D_CONDA_WORKSPACE%

IF "%LP3D_VERSION_INFO%" NEQ "" (
  REN %LP3D_VER_INFO_FILE% %LP3D_VER_INFO_NAME%.backup >NUL 2>&1
  >%LP3D_VER_INFO_FILE% ECHO %LP3D_VERSION_INFO%
  IF EXIST "%LP3D_VER_INFO_FILE%" (
    DEL /Q /S %LP3D_VER_INFO_PATH%\*.backup >NUL 2>&1
    ECHO - Version info updated to %LP3D_VERSION_INFO%.
  ) ELSE (
    REN %LP3D_VER_INFO_PATH%\%LP3D_VER_INFO_NAME%.backup %LP3D_VER_INFO_NAME%
    ECHO - WARNING - Version info was not updated.
  )
) ELSE (
  ECHO - WARNING - Version info variable was not defined.
)

ECHO - Build command: %LP3D_BUILD_COMMAND%

ECHO - Running %LP3D_CONDA_JOB%...
IF EXIST "%LP3D_BUILD_SCRIPT%" (
  CALL %LP3D_BUILD_COMMAND%
  IF NOT ERRORLEVEL 0 GOTO :ERROR_END
) ELSE (
  ECHO - ERROR - The build script %LP3D_BUILD_SCRIPT% was not found.
  GOTO :ERROR_END
)
CALL :GEN_MENU_SHORTCUT_JSON
CALL :CLEANUP_LDRAW_DIR
POPD
ECHO.
ECHO - %LP3D_CONDA_JOB% finished.
ENDLOCAL
EXIT /b 0

:GEN_MENU_SHORTCUT_JSON
IF NOT EXIST "%PREFIX%\Menu" (
  MKDIR "%PREFIX%\Menu" >NUL 2>&1
  IF ERRORLEVEL 1 (
    ECHO - ERROR - Create %PREFIX%\Menu folder failed.
    EXIT /b
  )
)
:: using menuinst 2.2
ECHO - Create %PKG_NAME%_menu.json
COPY /Y "%RECIPE_DIR%\lpub3d.ico" "%PREFIX%\Menu\LPub3D.ico" >NUL 2>&1
SET "GEN_SHORTCUT=%PREFIX%\Menu\%PKG_NAME%_menu.json"
SET genShortcut=%GEN_SHORTCUT% ECHO
 >%genShortcut% {
>>%genShortcut%    "menu_name": "LPub3D (64-bit)",
>>%genShortcut%    "menu_items": [
>>%genShortcut%       {
>>%genShortcut%          "name": "LPub3D (%PKG_VERSION%)",
>>%genShortcut%          "description": "An LDraw Building Instruction Editor",
>>%genShortcut%          "command": [ "${PREFIX}\\Library\\bin\\LPub3D.exe" ],
>>%genShortcut%          "icon": "${MENU_DIR}\\LPub3D.ico",
>>%genShortcut%          "working_dir": "${PREFIX}\\Library\\bin",
>>%genShortcut%          "platforms": {
>>%genShortcut%             "win": {
>>%genShortcut%                "desktop": false,
>>%genShortcut%                "quicklaunch": false
>>%genShortcut%             }
>>%genShortcut%          }
>>%genShortcut%       }
>>%genShortcut%    ],
>>%genShortcut%    "$schema": "https://schemas.conda.org/menuinst-1-1-0.schema.json"
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
ECHO - %LP3D_CONDA_JOB% FAILED!
ENDLOCAL
EXIT /b 1
