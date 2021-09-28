#!/bin/bash

make BUILD_TLS=yes
make PREFIX=$PREFIX install

if [[ "$target_platform" == osx* ]]; then
  make test
fi

mkdir -p "${PREFIX}/etc"

mkdir -p "${PREFIX}/var/run/redis"
mkdir -p "${PREFIX}/var/db/redis"

sed -i -e "s:/var/run/redis_6379.pid:${PREFIX}/var/run/redis.pid:g" redis.conf
sed -i -e "s:dir ./:dir ${PREFIX}/var/db/redis/:g" redis.conf

cp redis.conf "${PREFIX}/etc/redis.conf"
cp sentinel.conf "${PREFIX}/etc/redis-sentinel.conf"
