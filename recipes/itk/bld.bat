set POST=.post1
set PYPI_VER=%PY_VER:~0,1%%PY_VER:~2,1%

FOR %%D IN (core,io,filtering,numerics,registration) DO (
  %PYTHON% -m pip install --no-deps https://pypi.org/packages/cp%PYPI_VER%/i/itk-%%D/itk_%%D-%PKG_VERSION%%POST%-cp%PYPI_VER%-cp%PYPI_VER%m-win_amd64.whl
)
if errorlevel 1 exit 1
