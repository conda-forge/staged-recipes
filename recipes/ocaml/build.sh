#!/bin/bash
./configure -prefix $PREFIX
make world.opt
umask 022
make tests
make install
