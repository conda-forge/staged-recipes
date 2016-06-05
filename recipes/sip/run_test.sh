#!/bin/bash

cd test
sip -c . word.sip
python configure.py
make
