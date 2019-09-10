#!/bin/sh
sed -i.bak "s#g++#${CXX}#;s#/usr/local#${PREFIX}#;" makeMakefile.config
python makeMakefile.py
make
make install
