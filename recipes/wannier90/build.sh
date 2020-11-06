#!/bin/bash
cp ./config/make.inc.gfort.dynlib ./make.inc
make wannier
make tests
make install
