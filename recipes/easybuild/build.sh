#!/bin/bash

python setup.py install  \
	--single-version-externally-managed \
	--record=record.txt 

#$PREFIX/bin/python -O $PREFIX/lib/python2.7/site-packages/test/framework/suite.py
