#!/bin/bash

# install pineappl rust library with c-api support
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH
cargo install cargo-c
cd pineappl_capi
cargo cinstall --release --prefix=$PREFIX

# install python wrapper
cd ../wrappers/python
pip install . -vv
