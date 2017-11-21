#!/bin/bash

NTLK_DATA=$PREFIX/nltk_data
mkdir -vp $NTLK_DATA

# Download from the source of the package, its on the $SRC_DIR

mv $SRC_DIR/packages/* $NTLK_DATA
find $NTLK_DATA/ -name "*.zip" | while read filename; do unzip -qq -o -d "`dirname "$filename"`" "$filename"; done;
find $NTLK_DATA/ -name "*.gz" | while read filename; do gunzip "$filename"; done;

# Remove original zip files
find $NTLK_DATA/ -name "*.zip" -delete
find $NTLK_DATA/ -name "*.gz" -delete
