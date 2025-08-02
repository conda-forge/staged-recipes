@echo off
setlocal enabledelayedexpansion
set PY_VER=%PY_MAJOR%.%PY_MINOR%

@echo off
@REM Create target directories inside the Conda environment prefix
mkdir "%PREFIX%\share\dashingturtle\wheels"
mkdir "%PREFIX%\share\dashingturtle\tarballs"

@REM Copy wheel files from source
copy /Y "%SRC_DIR%\conda-recipe\wheels\*.whl" "%PREFIX%\share\dashingturtle\wheels\"

@REM Copy tar files from source
copy /Y "%SRC_DIR%\conda-recipe\wheels\*.tar*" "%PREFIX%\share\dashingturtle\tarballs\"

@REM Install varnaapi from local wheels directory without accessing PyPI
%PYTHON% -m pip install --no-index --find-links="%PREFIX%\share\dashingturtle\wheels" varnaapi

$PYTHON% -m pip install mariadb
$PYTHON% -m pip install snowflake-id
$PYTHON% -m pip install pysam

:: Install the package
cd "%SRC_DIR%"
:: PYTHON% -m pip install . --no-deps --ignore-installed -vv

:: Rename the original script
rename "%PREFIX%\Scripts\dt-gui.exe" .dt-gui-real.exe

:: Create a launcher script wrapper (dt-gui.bat)
(
echo @echo off
echo set QT_QPA_PLATFORM_PLUGIN_PATH=%PREFIX%\Library\plugins\platforms
echo "%PREFIX%\Scripts\.dt-gui-real.exe" %%*
) > "%PREFIX%\Scripts\dt-gui.bat"
