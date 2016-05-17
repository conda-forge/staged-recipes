cd "%SRC_DIR%"
py.test --cov=whichcraft
if errorlevel 1 exit 1
