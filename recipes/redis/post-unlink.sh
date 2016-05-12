if [[ $(id -u) == 0 ]] && [[ $(uname -s) == Linux ]]; then
    unlink /etc/redis
    unlink /var/db/redis
    unlink /var/log/redis
    unlink /var/run/redis
fi
