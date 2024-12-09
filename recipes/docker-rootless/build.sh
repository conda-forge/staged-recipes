#!/bin/bash
set -e

# Copy docker binaries to $PREFIX/bin
cp docker/* $PREFIX/bin/

# Copy rootless extras to $PREFIX/bin
cp -r docker-rootless-extras/* $PREFIX/bin/

# Ensure binaries are executable
chmod +x $PREFIX/bin/*
