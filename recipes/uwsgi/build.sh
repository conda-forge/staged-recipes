UWSGI_PROFILE="$RECIPE_DIR/uwsgi_config.ini" \
UWSGI_INCLUDES="$PREFIX/include,$PREFIX/include/openssl" \
    LDFLAGS="-L$PREFIX/lib" \
    $PYTHON setup.py install
