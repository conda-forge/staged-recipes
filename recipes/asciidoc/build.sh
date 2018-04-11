#!/bin/bash

export TERM=xterm

autoconf
./configure
make
sudo make install
