#!/bin/bash

set -ex

export PERL=$PREFIX/bin/perl

./configure --prefix=$PREFIX
make install
