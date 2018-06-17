#!/usr/bin/env python

import sys
import shlex
import pytest

tests = [
    '-v -s -m indexed_gzip_test --niters 250          --pyargs indexed_gzip -k "not drop_handles"',
    '-v -s -m indexed_gzip_test --niters 250 --concat --pyargs indexed_gzip -k "not drop_handles"'
]

for t in tests:
    if pytest.main(shlex.split(t)) != 0:
        sys.exit(1)

sys.exit(0)
