#!/usr/bin/env python

"""
script to dump a sha256 string for a file
"""
from __future__ import unicode_literals, print_function

import sys
import hashlib


if __name__ == "__main__":
    filename = sys.argv[1]
    print("the sha256 hex string is:")
    print(hashlib.sha256(open(filename,'rb').read()).hexdigest())
    print()
