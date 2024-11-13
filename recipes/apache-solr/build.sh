#!/bin/bash
set -ex
# Create the destination directories
mkdir -p $PREFIX/share/solr $PREFIX/bin

# Copy all files to the Conda environment directory
cp -r * $PREFIX/share/solr

# Create a wrapper script in $PREFIX/bin that calls the original solr script
cat << 'EOF' > $PREFIX/bin/solr
#!/bin/sh
SOLR_PATH=$(dirname $(readlink -f $0))/../share/solr
export SOLR_HOME=$(readlink -f $SOLR_PATH)
exec $SOLR_HOME/bin/solr "$@"
EOF
# Make the wrapper script executable
chmod +x $PREFIX/bin/solr
# Smoke test
cat $PREFIX/bin/solr
