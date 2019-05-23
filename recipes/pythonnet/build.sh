if [ "${SHORT_OS_STR:0:5}" == "Linux" ]; then
    cert-sync /etc/ssl/certs/ca-certificates.crt
fi

$PYTHON -m pip install . -vv
