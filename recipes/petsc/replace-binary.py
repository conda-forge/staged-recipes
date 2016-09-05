#!/usr/bin/env python
import sys, os, re

def replace_binary(data, a, b):
    def replace(match):
        count = match.group().count(a)
        padding = (len(a) - len(b)) * count
        assert padding >= 0
        return match.group().replace(a, b) + b'\0' * padding
    pat = re.compile(re.escape(a) + b'([^\0]*?)\0')
    res = pat.sub(replace, data)
    assert len(res) == len(data)
    return res

old = sys.argv[1].encode('utf-8')
new = sys.argv[2].encode('utf-8')
for path in sys.argv[3:]:
    path = os.path.realpath(path)
    with open(path, 'rb') as fi:
        old_data = fi.read()
    new_data = replace_binary(old_data, old, new)
    if new_data != old_data:
        with open(path, 'wb') as fo:
            fo.write(new_data)
