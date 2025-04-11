
@ECHO OFF &SETLOCAL

Title LPub3D Conda Build Test Script

REM This script uses Rattler-build for Conda-forge to perform the LPub3D
REM package content and build checks.
REM --
REM The primary purpose is to setup the 64bit build check environment to
REM successfully run the LPub3D build_checks.bat which will perform the
REM standard LPub3D build checks.
REM --
REM  Trevor SANDY <trevor.sandy@gmail.com>
REM  Last Update: March 22, 2025
REM  Copyright (C) 2023 - 2025 by Trevor SANDY
REM --
REM This script is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

SET "LP3D_APP=lpub3d"
SET "PACKAGE=LPub3D"
SET "CONFIGURATION=release"
SET "ABS_WD=%CD%\%LP3D_APP%"
SET "LDRAW_LIBS_ARCHIVE=%LIBRARY_PREFIX%\bin\extras\complete.zip"
SET "LDRAW_LIBS_DIR=lpub3d_windows_3rdparty"
SET "LDRAWDIR=%LDRAW_LIBS_DIR%\LDraw"
SET "LDRAW_LIBS=%CD%\%LDRAW_LIBS_DIR%"
SET "LOCALAPPDATA=%USERPROFILE%\AppData\Local"

SET "LP3D_CONDA_TEST=True"
SET "LP3D_7ZIP_WIN64=7z.exe"
SET "LP3D_TEST_COMMAND=.\%LP3D_APP%\builds\check\build_checks.bat"

SET "PACKAGE_LPUB3D=%LIBRARY_PREFIX%\bin\lpub3d.exe"
SET "PACKAGE_LDGLITE=%LIBRARY_PREFIX%\bin\3rdparty\ldglite-1.3\bin\ldglite.exe"
SET "PACKAGE_LDVIEW=%LIBRARY_PREFIX%\bin\3rdparty\ldview-4.5\bin\ldview64.exe"
SET "PACKAGE_POVRAY=%LIBRARY_PREFIX%\bin\3rdparty\lpub3d_trace_cui-3.8\bin\lpub3d_trace_cui64.exe"

IF NOT EXIST "%LP3D_APP%\builds\check" (
  ECHO - ERROR - Test assets %LP3D_APP%\builds\check not found.
  GOTO :ERROR_END
)

ECHO - Setup LDraw parts library...

IF NOT EXIST "%LDRAW_LIBS_DIR%" (
  MKDIR "%LDRAW_LIBS_DIR%" >NUL 2>&1
  IF NOT EXIST "%LDRAW_LIBS_DIR%" (
    ECHO - ERROR - Create %LDRAW_LIBS_DIR% failed.
    GOTO :ERROR_END
  )
)

IF NOT EXIST "%LDRAW_LIBS_DIR%\LDraw" (
  IF NOT EXIST "%LDRAW_LIBS_ARCHIVE%" (
    ECHO - ERROR - Parts library complete.zip was not found at %LDRAW_LIBS_ARCHIVE%.
    GOTO :ERROR_END
  ) ELSE (
    PUSHD %LDRAW_LIBS_DIR%
      7z.exe x -y "%LDRAW_LIBS_ARCHIVE%" >NUL 2>&1
    POPD
    IF NOT EXIST "%LDRAW_LIBS_DIR%\LDraw\parts" (
      ECHO - ERROR - Parts library complete.zip was not extracted.
      GOTO :ERROR_END
    )
  )
)

IF NOT EXIST "%USERPROFILE%\LDraw" (
  PUSHD %USERPROFILE%
  MKLINK /d LDraw %LDRAW_LIBS_DIR%\LDraw >NUL 2>&1
  POPD
  IF NOT EXIST "%USERPROFILE%\LDraw" (
    ECHO - ERROR - Create %USERPROFILE%\LDraw link failed.
    GOTO :ERROR_END
  ) ELSE (
    SET "CREATED_LDRAW_DIR=True"
  )
)

ECHO - Running package content test...
IF EXIST "%PACKAGE_LPUB3D%"  (ECHO - Package LPub3D Ok) ELSE (GOTO :ERROR_END)
IF EXIST "%PACKAGE_LDGLITE%" (ECHO - Package LDGLite Ok) ELSE (GOTO :ERROR_END)
IF EXIST "%PACKAGE_LDVIEW%"  (ECHO - Package LDView Ok) ELSE (GOTO :ERROR_END)
IF EXIST "%PACKAGE_POVRAY%"  (ECHO - Package POVRay Ok) ELSE (GOTO :ERROR_END)
ECHO - Running build test...
ECHO - Test command: %LP3D_TEST_COMMAND%
CALL %LP3D_TEST_COMMAND%
IF NOT ERRORLEVEL 0 GOTO :ERROR_END
CALL :CLEANUP_LDRAW_DIR
ECHO - Build test finished.
ENDLOCAL
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
ECHO - Build test FAILED!
ENDLOCAL
EXIT /b 1
