pip install -r requirements.txt
cd "%SRC_DIR%"
nosetests
if errorlevel 1 exit 1
