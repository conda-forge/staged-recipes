#!/usr/bin/env bash
#set -ex
#echo "================= PPR test $VDF_MODE"
##echo "----------------- PPR env"
##env
##echo "----------------- PPR python"
##which $PYTHON
##echo "PYTHON=$PYTHON"
#echo "----------------- PPR local run"
#sleep 0
#$PYTHON -c '
#import pandas
#import pathlib
#import os
#import glob
#print("------------ PPR ------------------")
#print(f"pandas.__file__={pandas.__file__}")
#print( glob.glob(str(pathlib.Path(pandas.__file__).parent.parent)+"/p*"))
#print( glob.glob(str(pathlib.Path(pandas.__file__).parent.parent)+"/v*"))
#'
#sleep 0
#echo "----------------- PPR normal run"
set -x
echo "Try to install"
$PYTHON -m pip install virtual_dataframe
$PYTHON -c 'import virtual_dataframe ; print(virtual_dataframe.VDF_MODE)'

