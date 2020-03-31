#!/bin/bash
set -e

make && make install

cp theseus-3.3.0 ${PREFIX}/bin