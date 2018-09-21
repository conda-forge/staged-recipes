#!/usr/bin/env bash
CONFIGURE="./configure --prefix=$PREFIX --enable-shared --disable-dependency-tracking --disable-crypto-dl --disable-apps-crypto-dl"
$CONFIGURE
make install
