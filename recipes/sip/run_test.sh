#!/bin/bash

cd test
sip -c . -b word.sbf word.sip
python configure.py
make
