import pefile
import sys
import os

def get_dependency(root):
    deps = []
    pe = pefile.PE(root)
    for imp in pe.DIRECTORY_ENTRY_IMPORT:
        deps.append(imp.dll.decode())
    return deps

root = sys.argv[1]
prefix = sys.argv[2]
dep_dlls = dict()
def dep_tree_impl(root, prefix):
    for dll in get_dependency(root):
        if dll in dep_dlls:
            continue
        full_path = os.path.join(prefix, dll)
        if os.path.exists(full_path):
            dep_dlls[dll] = full_path
            dep_tree_impl(full_path, prefix)
        else:
            dep_dlls[dll] = 'not found'
dep_tree_impl(root, prefix)
for dll, full_path in dep_dlls.items():
    print(' ' * 7, dll, '=>', full_path)
