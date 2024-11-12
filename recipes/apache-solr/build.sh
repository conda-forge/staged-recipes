#!/bin/bash

# Create the destination directories
mkdir -p $PREFIX/share/solr
mkdir -p $PREFIX/bin

# Copy all files to the Conda environment directory
cp -r * $PREFIX/share/solr

# Create a wrapper script in $PREFIX/bin that calls the original solr script
echo '#!/bin/sh' > $PREFIX/bin/solr
echo "SOLR_HOME=$PREFIX/share/solr" >> $PREFIX/bin/solr
echo "exec $PREFIX/share/solr/bin/solr \"\$@\"" >> $PREFIX/bin/solr

# Make the wrapper script executable
chmod +x $PREFIX/bin/solr
# Smoke test
cat $PREFIX/bin/solr
