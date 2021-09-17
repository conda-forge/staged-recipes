#!/bin/bash

make BUILD_TLS=yes
make PREFIX=$PREFIX install

if [[ "$target_platform" == osx* ]]; then
  make test
fi

mkdir -p "${PREFIX}/etc"

cp redis.conf "${PREFIX}/etc/redis.conf"
cp sentinel.conf "${PREFIX}/etc/redis-sentinel.conf"
