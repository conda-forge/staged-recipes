#!/bin/bash

make
make PREFIX=$PREFIX install
make test