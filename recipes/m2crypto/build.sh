#!/bin/bash

# Set the OPENSSL prefix so it doesn't link to /usr/lib/libssl
OPENSSL_PATH=$PREFIX $PYTHON setup.py install --single-version-externally-managed --record record.txt
