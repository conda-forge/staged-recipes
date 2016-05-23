setlocal enabledelayedexpansion
set CONDA_DEFAULT_ENV=

echo %PKG_VERSION% > conda\.version

%PYTHON% setup.py install --single-version-externally-managed --record=record.txt
if errorlevel 1 exit 1

del %SCRIPTS%\conda-init
if errorlevel 1 exit 1

mkdir %PREFIX%\exec

for %%X in (bash.exe) do (set FOUND=%%~$PATH:X)
if defined FOUND (
   set "FWD_PREFIX=%PREFIX:\=/%"
   bash -c "ln -s !FWD_PREFIX!/Scripts/activate !FWD_PREFIX!/exec/activate"
   bash -c "ln -s !FWD_PREFIX!/Scripts/conda.exe !FWD_PREFIX!/exec/conda.exe"
   bash -c "ln -s !FWD_PREFIX!/Scripts/conda-script.py !FWD_PREFIX!/exec/conda-script.py"
)

echo "%PREFIX%\Scripts\activate.bat" %%* > %PREFIX%\exec\activate.bat
echo "%PREFIX%\Scripts\conda.exe" %%* > %PREFIX%\exec\conda.bat

mkdir %PREFIX%\etc\fish\conf.d
echo "%SRC_DIR%\shell\conda.fish" %%* > %PREFIX%\etc\fish\conf.d\conda.fish
