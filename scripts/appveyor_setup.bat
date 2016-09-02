:: Find the recipes from master in this PR and remove them.
echo Finding recipes merged in master and removing them.
cd recipes
git fetch https://github.com/conda-forge/staged-recipes.git master
for /f "tokens=*" %%a in ('git ls-tree --name-only FETCH_HEAD -- .') do rmdir /s /q %%a && echo Removing recipe: %%a
cd ..

:: Set the CONDA_NPY, although it has no impact on the actual build. We need this because of a test within conda-build.
set CONDA_NPY=19

:: Remove cygwin (and therefore the git that comes with it).
rmdir C:\cygwin /s /q

:: Use the pre-installed Miniconda for the desired arch
::
:: However, it is really old. So, we need to update some
:: things before we proceed. That seems to require it being
:: on the path. So, we temporarily put conda on the path
:: so that we can update it. Then we remove it so that
:: we can do a proper activation.
set "OLDPATH=%PATH%"
set "PATH=%CONDA_INSTALL_LOCN%\\Scripts;%CONDA_INSTALL_LOCN%\\Library\\bin;%PATH%"
conda update --yes --quiet conda
set "PATH=%OLDPATH%"
call %CONDA_INSTALL_LOCN%\Scripts\activate.bat
conda config --add channels conda-forge
conda config --set show_channel_urls true
conda update --yes --quiet conda

conda install --yes --quiet obvious-ci conda-build-all
conda install --yes --quiet conda-forge-build-setup
run_conda_forge_build_setup
