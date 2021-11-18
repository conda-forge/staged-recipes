#!/bin/bash

set -x

mv foam $HOME/foam

source $HOME/foam/OpenFOAM-v2106/etc/bashrc

foam
