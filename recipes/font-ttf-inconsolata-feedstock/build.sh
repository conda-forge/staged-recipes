#!/bin/bash

mkdir -p ${PREFIX}/fonts || true
install -v -m644 ./ofl/inconsolata/Inconsolata-Regular.ttf ${PREFIX}/fonts/Inconsolata-Regular.ttf
install -v -m644 ./ofl/inconsolata/Inconsolata-Bold.ttf ${PREFIX}/fonts/Inconsolata-Bold.ttf
