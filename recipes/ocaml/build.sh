#!/bin/bash
./configure -prefix $PREFIX
make world.opt
make tests
make install
