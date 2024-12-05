#!/bin/bash
set -ex
# Build Solr with Gradle

# Install files
mkdir -p $PREFIX/share/solr $PREFIX/bin


# Copy Solr binaries to the share directory
cp -r * $PREFIX/share/solr

# Create symbolic links in $PREFIX/bin to the Solr wrapper scripts
ln -s $PREFIX/share/solr/bin/solr $PREFIX/bin/solr
ln -s $PREFIX/share/solr/bin/solr.cmd $PREFIX/bin/solr.cmd
