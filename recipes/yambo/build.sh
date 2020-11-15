#!/bin/bash
./configure ${PREFIX}
make yambo ypp interfaces
make install
