#!/bin/sh

libtoolize && autoreconf -i && ./configure --prefix=$PREFIX && make
