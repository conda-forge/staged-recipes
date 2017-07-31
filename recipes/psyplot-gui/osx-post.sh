#!/bin/bash
# Script to install the Psyplot.app on OSX
#
# This script runs after the installation on of the conda package on OSX.
# It creates a symbolic link name Psyplot.app in the /Applications folder or, if
# that doesn't work, in the $HOME/Applications folder.
#
# This link points to the Psyplot.app folder in this environment.
#
# Furthermore, since psyplot may be installed in different environments, we
# store the PREFIX of each environment in $HOME/.config/psyplot/psyplot-bins.txt
# where the top most environment will be used
set -e
PREFIXES_FILE=$HOME/.config/psyplot/psyplot-bins.txt

cp -r $PREFIX/psyplotapp $PREFIX/Psyplot.app
rm -rf $PREFIX/psyplotapp

# Don't overwrite existing directories with the link directories
if [[ -e  /Applications/Psyplot.app ]]; then
    if [[ ! -h /Applications/Psyplot.app ]]; then
        exit 0
    fi
elif [[ -e $HOME/Applications/Psyplot.app ]]; then
    if [[ ! -h $HOME/Applications/Psyplot.app ]]; then
        exit 0
    fi
fi
# otherwise create a link
ln -s -f $PREFIX/Psyplot.app /Applications/ >/dev/null 2>&1
if (( $? )); then
    mkdir -p $HOME/Applications
    ln -s -f $PREFIX/Psyplot.app $HOME/Applications/ || exit 0
fi

mkdir -p $HOME/.config/psyplot > /dev/null 2>&1

echo "$PREFIX" > ${PREFIXES_FILE}_new

if [[ -e $PREFIXES_FILE ]]; then
    cat $PREFIXES_FILE >> ${PREFIXES_FILE}_new
fi

mv ${PREFIXES_FILE}_new $PREFIXES_FILE
