@echo off
setlocal enabledelayedexpansion

if not exist "skills" (
    echo ERROR: skills\ directory not found in SRC_DIR: %CD%
    dir
    exit /b 1
)

set SHARE=%PREFIX%\share\bmad-utility-skills
if not exist "%SHARE%" mkdir "%SHARE%"
xcopy /E /I /Q skills "%SHARE%\skills\"
if errorlevel 1 exit /b 1
xcopy /E /I /Q .claude-plugin "%SHARE%\.claude-plugin\"
if errorlevel 1 exit /b 1
copy README.md "%SHARE%\"
if errorlevel 1 exit /b 1
copy AGENTS.md "%SHARE%\"
if errorlevel 1 exit /b 1
copy CLAUDE.md "%SHARE%\"
if errorlevel 1 exit /b 1
copy "%RECIPE_DIR%\LICENSE" "%SHARE%\"
if errorlevel 1 exit /b 1

if not exist "%PREFIX%\Scripts" mkdir "%PREFIX%\Scripts"
copy "%RECIPE_DIR%\bmad_utility_skills_install.py" "%PREFIX%\Scripts\bmad-utility-skills-install-script.py"
if errorlevel 1 exit /b 1
(
  echo @"%PREFIX%\python.exe" "%PREFIX%\Scripts\bmad-utility-skills-install-script.py" %%*
) > "%PREFIX%\Scripts\bmad-utility-skills-install.bat"
