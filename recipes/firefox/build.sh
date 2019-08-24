#!/bin/bash

mkdir -p ${PREFIX}/bin

if [ $(uname) == Linux ]; then
        mv * ${PREFIX}/bin
fi

if [ $(uname) == Darwin ]; then
  pkgutil --expand firefox.pkg firefox
  echo ${pwd}
  echo "HERE"
  ls -lha
  cpio --list --extract -I "firefox/Payload"
  echo "HERE"
  ls -lha
  echo "HERE"
  # cp usr/local/bin/* ${PREFIX}/bin/
fi
