pip install -r requirements.txt
cd "%SRC_DIR%"
py.test --cov=cookiecutter -k "not _hg_ and not mercurial"
if errorlevel 1 exit 1
