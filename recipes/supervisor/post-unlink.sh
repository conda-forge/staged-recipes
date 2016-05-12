if [[ $(id -u) == 0 ]]; then
    unlink /etc/supervisord
    unlink /etc/supervisord.conf
    unlink /var/log/supervisord
    unlink /var/run/supervisord
fi
