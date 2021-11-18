#!/bin/bash

set -x

mv foam $HOME/foam

cd $HOME/foam

. $HOME/foam/OpenFOAM-v2106/etc/bashrc

foam
