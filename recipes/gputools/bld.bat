
IF "%PY_VER%"=="2.7" (
	set SHA=8a6c8a996f12e89a1229ddc9ca96ff9cbe66dcf60a8aed3e1799cd811c65ef20
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/4c/6e/%SHA%/gputools-%PKG_VERSION%-py2-none-any.whl
)
IF "%PY_VER%"=="3.5" (
	set SHA=6581a7811abc22974ec2c8637ea3e08a4b00d69c05cc12d3ea50132502c8d479
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/69/59/%SHA%/gputools-%PKG_VERSION%-py3-none-any.whl
)
IF "%PY_VER%"=="3.6" (
	set SHA=6581a7811abc22974ec2c8637ea3e08a4b00d69c05cc12d3ea50132502c8d479
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/69/59/%SHA%/gputools-%PKG_VERSION%-py3-none-any.whl
)
if errorlevel 1 exit 1

