pip install -r requirements.txt
cd "%SRC_DIR%"
py.test
if errorlevel 1 exit 1
