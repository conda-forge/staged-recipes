#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -v -m644 ./ttf/DejaVuSans.ttf ${PREFIX}/fonts/DejaVuSans.ttf
