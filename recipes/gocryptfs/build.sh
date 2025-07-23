#!/bin/bash
set -e

# Build the binary
./build-without-openssl.bash

# Create bin directory if it doesn't exist
mkdir -p "${PREFIX}/bin"

# Copy the resulting binary into the Conda environment's bin
cp gocryptfs "${PREFIX}/bin/"
