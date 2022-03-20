#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -v -m644 Variable/TTF/*.ttf ${PREFIX}/fonts/
install -v -m644 Variable/TTF/Mono/*.ttf ${PREFIX}/fonts/
