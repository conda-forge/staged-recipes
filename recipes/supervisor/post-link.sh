if [[ $(id -u) == 0 ]]; then
    mkdir -p /etc/supervisord/ && ln -s $PREFIX/etc/supervisord/ /etc/supervisord/
    ln -s $PREFIX/etc/supervisord.conf /etc/supervisord.conf
    mkdir -p /var/log/supervisord/ && ln -s $PREFIX/var/log/supervisord/ /var/log/supervisord/
    mkdir -p /var/run/supervisord/ && ln -s $PREFIX/var/run/supervisord/ /var/run/supervisord/
fi
