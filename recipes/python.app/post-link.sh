#!/bin/bash

cp -r "$PREFIX/pythonapp" "$PREFIX/python.app"
rm -rf "$PREFIX/pythonapp"

cd "$PREFIX/python.app/Contents"
ln -s ../../lib .
