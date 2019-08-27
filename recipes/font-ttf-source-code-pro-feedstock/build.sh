#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -v -m644 ./TTF/*.ttf ${PREFIX}/fonts/
