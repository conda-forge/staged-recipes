#!/bin/bash

set -ex

INTLTOOL_PERL=$PREFIX/bin/perl ./configure --prefix=$PREFIX
make install
