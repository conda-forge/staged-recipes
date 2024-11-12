#!/bin/sh
set -ex
# Create directories for Conda environment
mkdir -p $PREFIX/share/solr

# Copy the downloaded and extracted Solr files into the Conda environment
cp -r * $PREFIX/share/solr/

# Make solr executable available in PATH
ln -s $PREFIX/share/solr/bin/solr $PREFIX/bin/solr

