@echo on

"%PYTHON%" -c "import dpctl"
if errorlevel 1 exit 1

python -m pytest -q -ra --disable-warnings --pyargs dpctl -vv
if errorlevel 1 exit 1
