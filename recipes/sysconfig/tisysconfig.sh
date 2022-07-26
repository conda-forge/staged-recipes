#!/bin/sh
#
# Run the SysConfig command line tool
#
# For help, use -h or --help

tisysconfig_dir=$CONDA_PREFIX/lib/tisysconfig/dist/

nodeFlags=""
if [ "$1" = "-g" ]; then
    shift
    nodeFlags="$nodeFlags --inspect --debug-brk"
fi

node $nodeFlags "$tisysconfig_dir/cli.js" "$@"
