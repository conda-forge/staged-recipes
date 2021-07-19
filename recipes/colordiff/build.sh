#!/bin/bash

set -xe

make INSTALL_DIR= DESTDIR=$PREFIX install
