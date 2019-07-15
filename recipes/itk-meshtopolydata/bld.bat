set POST=
set PYPI_VER=%PY_VER:~0,1%%PY_VER:~2,1%

%PYTHON% -m pip install --no-deps https://pypi.org/packages/cp%PYPI_VER%/i/itk-meshtopolydata/itk_meshtopolydata-%PKG_VERSION%%POST%-cp%PYPI_VER%-cp%PYPI_VER%m-win_amd64.whl

if errorlevel 1 exit 1
