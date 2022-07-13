#!/bin/sh
#
# Run the SysConfig command line tool
#
# For help, use -h or --help

tisysconfig_dir=$CONDA_PREFIX/Library/lib/tisysconfig/dist/

nodeFlags=""
if [ "$1" = "-g" ]; then
    shift
    nodeFlags="$nodeFlags --inspect --debug-brk"
fi

nodejs $nodeFlags "$tisysconfig_dir/cli.js" "$@"
