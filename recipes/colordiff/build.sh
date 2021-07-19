#!/bin/bash

set -xe

sed -i.bak 's,/usr/bin/perl -w,/usr/bin/env perl,' colordiff.pl

make INSTALL_DIR= DESTDIR=$PREFIX install
