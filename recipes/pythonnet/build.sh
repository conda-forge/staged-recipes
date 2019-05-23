if [ "${SHORT_OS_STR:0:5}" == "Linux" ]; then
    cert-sync $PREFIX/ssl/cacert.pem
fi

$PYTHON -m pip install . -vv
