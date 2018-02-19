#!/bin/bash
distrib/hc-build --prefix=$PREFIX
sed -e '2374,2398d;' configure
make install
