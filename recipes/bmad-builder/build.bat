@echo off
setlocal enabledelayedexpansion

if not exist "skills" (
    echo ERROR: skills\ directory not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

:: Install skill files and Claude plugin config
if not exist "%PREFIX%\share\bmad-builder" mkdir "%PREFIX%\share\bmad-builder"
xcopy /E /I /Q skills "%PREFIX%\share\bmad-builder\skills\"
if errorlevel 1 exit /b 1
xcopy /E /I /Q .claude-plugin "%PREFIX%\share\bmad-builder\.claude-plugin\"
if errorlevel 1 exit /b 1
copy CHANGELOG.md "%PREFIX%\share\bmad-builder\"
if errorlevel 1 exit /b 1
copy LICENSE "%PREFIX%\share\bmad-builder\"
if errorlevel 1 exit /b 1
copy README.md "%PREFIX%\share\bmad-builder\"
if errorlevel 1 exit /b 1

:: Install Python entry point wrapper
if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
copy "%RECIPE_DIR%\bmad_builder_install.py" "%PREFIX%\Scripts\bmad-builder-install-script.py"
if errorlevel 1 exit /b 1
(
  echo @"%PREFIX%\python.exe" "%PREFIX%\Scripts\bmad-builder-install-script.py" %%*
) > "%PREFIX%\Scripts\bmad-builder-install.bat"
