# handle conda...      >=4.1.3        <= 4.1.2
export SSL_CERT_DIR="${CONDA_PREFIX}${CONDA_ENV_PATH}/ssl"
export SSL_CERT_FILE="${SSL_CERT_DIR}/cacert.pem"
