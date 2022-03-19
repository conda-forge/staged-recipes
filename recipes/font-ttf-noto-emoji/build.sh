#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -v -m644 *.ttf ${PREFIX}/fonts/
install -v -m644 *.otf ${PREFIX}/fonts/



