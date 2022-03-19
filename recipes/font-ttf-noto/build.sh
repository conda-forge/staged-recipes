#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -v -m644 unhinted/variable-ttf/*.ttf ${PREFIX}/fonts/



