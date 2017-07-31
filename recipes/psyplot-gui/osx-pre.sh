#!/bin/bash
# Script to uninstall the Psyplot.app on OSX
#
# This script runs after the deinstallation on of the conda package on OSX.
# It deletes the symbolic link named Psyplot.app in the /Applications folder or,
# if that doesn't exist, in the $HOME/Applications folder.
#
# If there exist another psyplot installation in another conda environment, the
# existing is overwritten to that PREFIX
set -e

PREFIXES_FILE="$HOME/.config/psyplot/psyplot-bins.txt"

if [[ -e ${PREFIXES_FILE}_new ]]; then
    rm ${PREFIXES_FILE}_new
fi

while IFS='' read -r CURRENT_PREFIX; do
    if [[ $CURRENT_PREFIX != $PREFIX ]]; then
        echo $CURRENT_PREFIX > ${PREFIXES_FILE}_new
    fi
done < $PREFIXES_FILE

if [[ -e ${PREFIXES_FILE}_new ]]; then
    mv ${PREFIXES_FILE}_new $PREFIXES_FILE
else
    rm ${PREFIXES_FILE}
    rm -f /Applications/Psyplot.app
    rm -f "$HOME/Applications/Psyplot.app"
    exit 0
fi

LINKNAME=""
if [[ -e /Applications/Psyplot.app ]]; then
    LINKNAME=/Applications/Psyplot.app
elif [[ -e "$HOME/Applications/Psyplot.app" ]]; then
    LINKNAME="$HOME/Applications/Psyplot.app"
fi
echo $LINKNAME
if [[ $LINKNAME != "" ]]; then
    if [[ -h $LINKNAME ]]; then  # if it is a link, check it
        TARGET=`readlink $LINKNAME`
        if (( $? )); then  # assume GNU readlink
            TARGET=`readlink -f $LINKNAME`
        fi
        if [[ "$TARGET" == "$PREFIX/Psyplot.app" ]]; then
            rm $LINKNAME
            ln -s `head -n 1 $PREFIXES_FILE`/Psyplot.app $LINKNAME
        fi
    fi
fi

rm -rf "$PREFIX/Psyplot.app"
