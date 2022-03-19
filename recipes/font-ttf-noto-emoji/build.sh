#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -v -m644 fonts/*.ttf ${PREFIX}/fonts/
