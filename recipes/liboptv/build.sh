#!/bin/bash

cd ../py_bind
python setup.py prepare
python setup.py install
cd test
nosetests
