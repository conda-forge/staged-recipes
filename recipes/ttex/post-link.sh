#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Generate the .fmt files, some of which embed absolute paths in a way that
# can't be patched up using Conda's standard methods. We don't want to annoy
# the user with reams of output if everything is OK, but we need to be
# debuggable if not, so we jump through some hoops. The logic below is based
# on some brief trial-and-error and may need improvement.

temp=$(mktemp)

$PREFIX/bin/fmtutil-sys --all >$temp 2>&1
rc=$?
if [ $rc -ne 0 ] ; then
    # Definite error, write output to .messages.txt so that the message will
    # be displayed by conda
    cat $temp >>$PREFIX/.messages.txt
    rm -f $temp
    exit 1
fi
