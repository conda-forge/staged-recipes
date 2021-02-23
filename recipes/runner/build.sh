#!/bin/bash
cd src
make serial
mkdir -p ${PREFIX}/bin
cp RuNNer.serial.x ${PREFIX}/bin
