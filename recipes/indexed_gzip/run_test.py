#!/usr/bin/env python

import sys
import shlex
import pytest

if __name__ == '__main__':

    tests = [
        '-v -s -m indexed_gzip_test --niters 250          --pyargs indexed_gzip -k "not drop_handles"',
        '-v -s -m indexed_gzip_test --niters 250 --concat --pyargs indexed_gzip -k "not drop_handles"'
    ]

    for t in tests:
        # we get weird exit codes under windows
        if pytest.main(shlex.split(t)) not in (0, -1073740791):
            sys.exit(1)

    sys.exit(0)
