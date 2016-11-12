#!/bin/bash

cd miniampl
make
bin/miniampl examples/wb showname=1 showgrad=1 | grep -q "f(x0) = -2.0"
