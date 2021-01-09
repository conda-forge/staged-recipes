#!/bin/bash

set -e

# install library
${PYTHON} -m pip install . -vv

# install manpage
_MANDIR="${PREFIX}/man/man1"
install -d -m 0755 ${_MANDIR}
install -m 0644 orig/Documentation/man1/git-filter-repo.1 ${_MANDIR}/git-filter-repo.1
