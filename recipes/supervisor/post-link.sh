if [[ $(id -u) == 0 ]]; then
    ln -s $PREFIX/etc/supervisord/ /etc/supervisord/
    ln -s $PREFIX/etc/supervisord.conf /etc/supervisord.conf
    ln -s $PREFIX/var/log/supervisord/ /var/log/supervisord/
    ln -s $PREFIX/var/run/supervisord/ /var/run/supervisord/
fi
