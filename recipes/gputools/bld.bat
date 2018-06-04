
IF "%PY_VER%"=="2.7" (
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/4c/6e/95b8705958727580f0168fa210856ac14db31c69f0e3ea2bb53b57a5c268/gputools-0.2.6-py2-none-any.whl
)
IF "%PY_VER%"=="3.5" (
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/69/59/6cddcc42db5feeddbaa0b92605e544698f0ecf00b6b8c25c5aa623d97513/gputools-0.2.6-py3-none-any.whl
)
IF "%PY_VER%"=="3.6" (
	%PYTHON% -m pip install --no-deps https://files.pythonhosted.org/packages/69/59/6cddcc42db5feeddbaa0b92605e544698f0ecf00b6b8c25c5aa623d97513/gputools-0.2.6-py3-none-any.whl
)
if errorlevel 1 exit 1

