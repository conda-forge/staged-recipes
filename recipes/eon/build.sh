#!/bin/bash

# server
python -m pip install . -vv --no-deps --no-build-isolation

# client 
cd client
make NO_FORTRAN=1
