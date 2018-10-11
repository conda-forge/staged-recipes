IF "%PY_VER%"=="3.5" (
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/d9/43/71cb8168f020dce3a02873809aa5d0d3e4cefedfc5146076f447d4bd1090/ecell-4.1.4-cp35-cp35m-win_amd64.whl
)

IF "%PY_VER%"=="3.6" (
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/7f/8c/798d65bd2210b2f74653d7ca73f268587b02079419319bc9cb7af7183a5e/ecell-4.1.4-cp36-cp36m-win_amd64.whl
)
if errorlevel 1 exit 1
