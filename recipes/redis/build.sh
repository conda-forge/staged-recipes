unset ARCH  # https://github.com/redis/hiredis-rb/issues/2
make distclean
make PREFIX=$PREFIX install

## configuration ##
mkdir -p $PREFIX/etc/redis/
curl -sS -O $PREFIX/etc/redis/redis.conf \
    https://raw.githubusercontent.com/antirez/redis/${MAJOR_MINOR_VERSION}/redis.conf
cp $RECIPE_DIR/redis-conda.conf $PREFIX/etc/redis/conda.conf
printf "\n\n" >> $PREFIX/etc/redis/redis.conf
printf "include $PREFIX/etc/redis/conda.conf\n" >> $PREFIX/etc/redis/redis.conf

## other directories ##
mkdir -p $PREFIX/var/log/supervisord
mkdir -p $PREFIX/var/db/redis
mkdir -p $PREFIX/var/run/redis
