#!/bin/bash
export LC_ALL=C
./configure -prefix $PREFIX
make world.opt
umask 022
make install
