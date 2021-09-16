#!/bin/bash

make BUILD_TLS=yes
make PREFIX=$PREFIX install
make test