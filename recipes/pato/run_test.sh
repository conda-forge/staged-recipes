#!/bin/bash
set -e  # exit when any command fails
set -x # show the commands

echo -e "\n### TESTING PATO ###\n"
which runtests
export PATO_DIR=$SRC_DIR/volume/PATO/PATO-dev-2.3.1
runtests
