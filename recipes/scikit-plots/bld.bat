@echo on

:: Inspired by the numpy-feedstock build script:
:: https://github.com/conda-forge/numpy-feedstock/blob/main/recipe/bld.bat

mkdir builddir

:: -wnx flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x ^
    -Cbuilddir=builddir 
if %ERRORLEVEL% neq 0 exit 1

:: `pip install dist\*.whl` does not work on windows,
:: so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\dist') do (
    pip install %%f
    if %ERRORLEVEL% neq 0 exit 1
)
