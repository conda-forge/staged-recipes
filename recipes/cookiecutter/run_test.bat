pip install -r requirements.txt
cd "%SRC_DIR%"
py.test --cov=cookiecutter -k 'not _hg_'
if errorlevel 1 exit 1
