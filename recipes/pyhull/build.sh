#!/bin/bash 
patch < pyhull.patch
python -m pip install . -vvv
