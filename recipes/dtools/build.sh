#!/bin/bash
make -f posix.mak all INSTALL_DIR=$PREFIX DMD=ldmd2 CC="${CC}"
make -f posix.mak install INSTALL_DIR=$PREFIX DMD=ldmd2 CC="${CC}"
