pip install -r requirements.txt
cd "%SRC_DIR%"
python setup.py test
if errorlevel 1 exit 1
