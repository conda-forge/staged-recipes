#!/bin/bash

# check 
ls 
cd eon-2521

# server
python -m pip install . -vv --no-deps --no-build-isolation

# client 
cd client
make
