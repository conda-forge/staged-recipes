#!/bin/bash

set -x

# Skip man files due to XML dependencies
sed -i.bak 's/^MANS=.*/MANS=/' Makefile
sed -i.bak 's/install $(MANS)/# install $(MANS)/' Makefile

# Fix perl path
for f in vipe ts vidir zrun chronic; do
    sed -i.bak 's,#!/usr/bin/perl,#!/usr/bin/env perl,' $f
done

make PREFIX=$PREFIX CC=$CC
make install PREFIX=$PREFIX CC=$CC
