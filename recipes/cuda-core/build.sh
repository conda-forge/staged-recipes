#!/bin/bash

DIR_NAME="$(echo $PKG_NAME | tr '-' '_')"
cd $DIR_NAME
$PYTHON -m pip install . --no-deps -vv
