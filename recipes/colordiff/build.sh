#!/bin/bash

set -xe

make INSTALL_DIR= DEST_DIR=$PREFIX install
