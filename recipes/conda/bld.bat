setlocal enabledelayedexpansion

:: Remove links and other scripts.
del %PREFIX%\Scripts\activate
del %PREFIX%\Scripts\activate.bat
del %PREFIX%\Scripts\deactivate
del %PREFIX%\Scripts\deactivate.bat

:: Prep conda install
set CONDA_DEFAULT_ENV=
echo %PKG_VERSION% > conda\.version

:: Install the Python code
%PYTHON% conda.recipe\setup.py install
if errorlevel 1 exit 1

:: Install fish activation script.
mkdir "%PREFIX%\etc\fish\conf.d"
if errorlevel 1 exit 1
copy "%SRC_DIR%\shell\conda.fish" "%PREFIX%\etc\fish\conf.d"
if errorlevel 1 exit 1
