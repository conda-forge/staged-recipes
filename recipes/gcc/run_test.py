import subprocess
import os

def otool(path):
    "thin wrapper around otool -L"
    lines = subprocess.check_output(['otool', '-L', path]).decode('utf-8').splitlines()
    assert lines[0].startswith(path), path
    res = []
    for line in lines[1:]:
        assert line[0] == '\t'
        res.append(line.split()[0])
    return res

def assert_relative_osx(path):
    for name in otool(path):
        assert not 'placehold' in name, path

prefix = os.environ['PREFIX']

for f in os.listdir(os.path.join(prefix, 'lib')):
    if f.endswith('dylib'):
        assert_relative_osx(os.path.join(prefix, 'lib', f))
