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
        code = pytest.main(shlex.split(t))

        print('pytest exit code', code)
        if code != 0:
            sys.exit(1)

    sys.exit(0)
