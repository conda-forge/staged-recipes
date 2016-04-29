set UWSGI_PROFILE=%RECIPE_DIR%/uwsgi_config.ini
set UWSGI_INCLUDES=%PREFIX%/include,%PREFIX%/include/openssl
set LDFLAGS=-L%PREFIX%/lib

python setup.py install
if errorlevel 1 exit 1
