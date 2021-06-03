import os
import sys

sp_dir, library_lib, library_bin, imp_init = sys.argv[1:]

search_dirs = [os.path.relpath(x, sp_dir) for x in (library_lib, library_bin)]

patch = """
# Anaconda installs DLLs that we depend on in Library\\lib or Library\\bin,
# so we need to add those directories to the DLL search path (PATH variable)
def __add_dll_search_path():
    import sys
    import os
    path = os.environ['PATH'].split(";")
    our_dir = os.path.dirname(__file__)
    search_dirs = [os.path.abspath(os.path.join(our_dir, x))
                   for x in %s]
    for d in search_dirs:
        if d not in path:
            path.insert(0, d)
    os.environ['PATH'] = ";".join(path)
__add_dll_search_path()

""" % repr(search_dirs)

with open(imp_init) as fh:
    contents = fh.read()
if 'add_dll_search_path' not in contents:
    patched = False
    with open(imp_init, 'w') as fh:
        for line in contents.split('\n'):
            if line.startswith('import ') and not patched:
                fh.write(patch)
                patched = True
            fh.write(line)
            fh.write('\n')
    if not patched:
        raise RuntimeError("Unable to apply patch")
