if [[ $(id -u) == 0 ]] && [[ $(uname -s) == Linux ]]; then
    mkdir -p /etc/ && ln -s $PREFIX/etc/redis /etc/
    mkdir -p /var/db/ && ln -s $PREFIX/var/db/redis /var/db/
    mkdir -p /var/log/ && ln -s $PREFIX/var/log/redis /var/log/
    mkdir -p /var/run/ && ln -s $PREFIX/var/run/redis /var/run/
fi
