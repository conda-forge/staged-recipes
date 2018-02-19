#!/bin/bash
sed -e '2374,2398d;' configure
distrib/hc-build --prefix=$PREFIX
make install
