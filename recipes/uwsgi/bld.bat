set UWSGI_PROFILE=%RECIPE_DIR%/uwsgi_config.ini
set UWSGI_INCLUDES=%PREFIX%/include,%PREFIX%/include/openssl
set LDFLAGS=-L%PREFIX%/lib

%PYTHON% setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
