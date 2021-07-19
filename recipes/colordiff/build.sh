#!/bin/bash

set -xe

sed -i.bak s,/usr/bin/perl,/usr/bin/env perl, colordiff.pl

make INSTALL_DIR= DESTDIR=$PREFIX install
