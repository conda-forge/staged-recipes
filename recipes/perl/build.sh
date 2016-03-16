#!/bin/bash
sh Configure -de -Dprefix=$PREFIX -Duserelocatableinc
make
make test
make install
