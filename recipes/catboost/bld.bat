IF "%PY_VER%"=="2.7" (
	%PYTHON% -m pip install --no-deps https://pypi.org/packages/cp27/c/catboost/catboost-%PKG_VERSION%-cp27-none-win_amd64.whl
)

IF "%PY_VER%"=="3.4" (
	%PYTHON% -m pip install --no-deps https://pypi.org/packages/cp34/c/catboost/catboost-%PKG_VERSION%-cp34-none-win_amd64.whl
)

IF "%PY_VER%"=="3.5" (
	%PYTHON% -m pip install --no-deps https://pypi.org/packages/cp35/c/catboost/catboost-%PKG_VERSION%-cp35-none-win_amd64.whl
)

IF "%PY_VER%"=="3.6" (
	%PYTHON% -m pip install --no-deps https://pypi.org/packages/cp36/c/catboost/catboost-%PKG_VERSION%-cp36-none-win_amd64.whl
)
if errorlevel 1 exit 1
