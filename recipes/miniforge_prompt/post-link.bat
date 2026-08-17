SETLOCAL ENABLEDELAYEDEXPANSION

REM The menuinst v2 json file is not compatible with menuinst versions
REM older than 2.1.1. Copy the appropriate file as the menu file.

SET LOGFILE=%PREFIX%\.messages.txt
SET MENU_DIR=%PREFIX%\Menu
SET MENU_PATH=%MENU_DIR%\%PKG_NAME%_menu.json

IF EXIST "%CONDA_PYTHON_EXE%" (
    SET PYTHON_CMD="%CONDA_PYTHON_EXE%"
    GOTO :get_menuinst
)

IF EXIST "%PREFIX%\_conda.exe" (
    SET PYTHON_CMD="%PREFIX%\_conda.exe" python
    GOTO :get_menuinst
)

GOTO :menuinst_too_old

:get_menuinst
%PYTHON_CMD% -c "import menuinst, sys; sys.exit(1 if tuple(int(x) for x in menuinst.__version__.split('.'))[:3] < (2, 1, 1) else 0)"
IF %ERRORLEVEL% == 1 GOTO :menuinst_too_old

%PYTHON_CMD% -c "import os, sys; from pathlib import Path; from menuinst.utils import _default_prefix; sys.exit(int(Path(os.environ['PREFIX']).samefile(_default_prefix(which='base'))))"
IF %ERRORLEVEL% == 0 (
    CALL :patch "__ENV_PLACEHOLDER__= ^({{ ENV_NAME }}^)"
    CALL :patch "__ENV_PLACEHOLDER_TERMINAL__=/{{ ENV_NAME }}"
) ELSE (
    CALL :patch "__ENV_PLACEHOLDER__="
    CALL :patch "__ENV_PLACEHOLDER_TERMINAL__="
)
GOTO :exit

:patch
    SET TMPMENU=%MENU_DIR%\%PKG_NAME%_menu_tmp.json
    SET FINDREPLACE=%~1
    FOR /f "delims=" %%i IN ('type "%MENU_PATH%"') DO (
        SET s=%%i
        ECHO !s:%FINDREPLACE%!>> "%TMPMENU%"
    )
    MOVE /Y "%TMPMENU%" "%MENU_PATH%"
    GOTO :eof

:menuinst_too_old:
    ECHO. >> "%LOGFILE%"
    ECHO This package requires menuinst v2.1.1 in the base environment. >> "%LOGFILE%"
    ECHO Please update menuinst in the base environment and reinstall %PKG_NAME%. >> "%LOGFILE%"
    EXIT /B 1

:exit
    EXIT /B %ERRORLEVEL%
