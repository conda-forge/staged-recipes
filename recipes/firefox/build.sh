#!/bin/bash

mkdir -p ${PREFIX}/bin

if [ $(uname) == Linux ]; then
        mv * ${PREFIX}/bin
fi

if [ $(uname) == Darwin ]; then
  pkgutil --expand firefox.pkg firefox
  echo ${pwd}
  cpio -i -I "firefox/Payload"
  echo "HERE"
  ls -lha
  echo "HERE"
  ls -lha firefox
  # cp usr/local/bin/* ${PREFIX}/bin/
fi
