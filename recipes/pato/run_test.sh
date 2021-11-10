#!/bin/bash
set -e  # exit when any command fails

echo -e "\n### TESTING PATO ###\n"
echo $PATO_DIR
runtests
