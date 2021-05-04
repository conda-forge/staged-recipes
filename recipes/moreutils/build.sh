#!/bin/bash

set -x

# Skip man files due to XML dependencies
sed -i 's/^MANS=.*/MANS=/' Makefile
sed -i 's/install $(MANS)/# install $(MANS)/' Makefile

make PREFIX=$PREFIX CC=$CC
make install PREFIX=$PREFIX CC=$CC
