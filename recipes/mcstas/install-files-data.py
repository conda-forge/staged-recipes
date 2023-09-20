#!/usr/bin/env python3
import os
import pathlib

prefix = pathlib.Path(os.environ['PREFIX']).absolute().resolve()
assert prefix.is_dir()
dest = prefix / 'share' / 'mcstas' / 'resources' / 'data'
src = ( pathlib.Path('.') / 'src' / 'mcstas-comps' / 'data' ).absolute().resolve()
assert src.is_dir()

_print=print
def print(*args,**kwargs):
    _print('install-files-data.py::',*args,**kwargs)
def fatal_error(*args,**kwargs):
    _print('ERROR install-files-data.py::',*args,**kwargs)
    raise SystemExit(1)

n_added = 0
for forig in src.glob('**/*'):
    f = forig.absolute().resolve()
    if not f.is_relative_to(src):
        fatal_error('Data-file is symlink: ',forig)
    subpath = f.relative_to(src)
    if any( str(subpath).startswith(c) for c in '._' ):
        print('Ignoring file with forbidden initial character: %s'%subpath)
        continue
    if any( ( c in str(subpath) ) for c in '~#' ):
        print('Ignoring file with forbidden (backup?) character in name: %s'%subpath)
        continue
    if any( ( c in str(subpath) ) for c in '$^: \t\n'):
        fatal_error('Forbidden character in name: %s'%subpath)
    if f.is_dir():
        continue
    target = dest / subpath
    target.parent.mkdir(parents=True, exist_ok=True)
    print('Adding %s'%subpath)
    #Transfer the data content only (i.e. do not use shutil.copy) to make doubly
    #sure we clear any weird permission bits on the input file, break symlinks,
    #etc.:
    target.write_bytes( f.read_bytes() )
    n_added += 1

if n_added == 0:
    fatal_error('Did not add ANY data files in mcstas-data package!')
if n_added > 2000:
    fatal_error('Suspiciously high number of data files added in mcstas-data package!')
