:: PLEASE NOTE: This script has been automatically generated by conda-smithy. Any changes here
:: will be lost next time ``conda smithy rerender`` is run. If you would like to make permanent
:: changes to this script, consider a proposal to conda-smithy so that other feedstocks can also
:: benefit from the improvement.

:: Note: we assume a Miniforge installation is available

:: INPUTS (required environment variables)
:: CONDA_BLD_PATH: path for the conda-build workspace
:: CI: azure, or unset

setlocal enableextensions enabledelayedexpansion

call :start_group "Configuring conda"

if "%CONDA_BLD_PATH%" == "" (
    set "CONDA_BLD_PATH=C:\bld"
)

:: Activate the base conda environment
call activate base

conda.exe config --set always_yes yes
if errorlevel 1 exit 1
conda.exe config --set channel_priority strict
if errorlevel 1 exit 1
conda.exe config --set solver libmamba
if errorlevel 1 exit 1

echo Installing dependencies
conda.exe install --file .\.ci_support\requirements.txt
if errorlevel 1 exit 1

:: Set basic configuration
echo Setting up configuration
setup_conda_rc .\ ".\recipes" .\.ci_support\%CONFIG%.yaml
if errorlevel 1 exit 1

echo Run conda_forge_build_setup
call run_conda_forge_build_setup
if errorlevel 1 exit 1

echo Force fetch origin/main
git fetch --force origin main:main
if errorlevel 1 exit 1
echo Removing recipes also present in main
cd recipes
for /f "tokens=*" %%a in ('git ls-tree --name-only main -- .') do rmdir /s /q %%a && echo Removing recipe: %%a
cd ..

:: make sure there is a package directory so that artifact publishing works
if not exist "%CONDA_BLD_PATH%\win-64\" mkdir "%CONDA_BLD_PATH%\win-64\"
if not exist "%CONDA_BLD_PATH%\noarch\" mkdir "%CONDA_BLD_PATH%\noarch\"

echo Index %CONDA_BLD_PATH%
conda.exe index "%CONDA_BLD_PATH%"
if errorlevel 1 exit 1

call :end_group

echo Building all recipes
python .ci_support\build_all.py --arch 64
if errorlevel 1 exit 1

call :start_group "Inspecting artifacts"

:: inspect_artifacts was only added in conda-forge-ci-setup 4.6.0
WHERE inspect_artifacts >nul 2>nul && inspect_artifacts || echo "inspect_artifacts needs conda-forge-ci-setup >=4.6.0"

call :end_group

exit

:: Logging subroutines

:start_group
if /i "%CI%" == "github_actions" (
    echo ::group::%~1
    exit /b
)
if /i "%CI%" == "azure" (
    echo ##[group]%~1
    exit /b
)
echo %~1
exit /b

:end_group
if /i "%CI%" == "github_actions" (
    echo ::endgroup::
    exit /b
)
if /i "%CI%" == "azure" (
    echo ##[endgroup]
    exit /b
)
exit /b
