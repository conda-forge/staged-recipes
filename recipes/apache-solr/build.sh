#!/bin/bash

# Create the destination directories
mkdir -p $PREFIX/share/solr $PREFIX/bin

# Copy all files to the Conda environment directory
cp -r * $PREFIX/share/solr

# Create a wrapper script in $PREFIX/bin that calls the original solr script
cat << 'EOF' > $PREFIX/bin/solr
#!/bin/sh
SOLR_HOME=$PREFIX/share/solr
exec $PREFIX/share/solr/bin/solr "$@"
EOF

# Make the wrapper script executable
chmod +x $PREFIX/bin/solr
