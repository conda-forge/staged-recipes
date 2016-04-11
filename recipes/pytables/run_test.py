import sys
import os
import tables
import tables._comp_bzip2
# We don't build this one on Windows.
if not sys.platform == "win32":
    import tables._comp_lzo
import tables.hdf5extension
import tables.indexesextension
import tables.linkextension
import tables.lrucacheextension
import tables.tableextension
import tables.utilsextension

tables.print_versions()

if sys.platform.startswith('linux'):
    lzo_ver = tables.which_lib_version("lzo")[1]
    assert lzo_ver == '2.06', lzo_ver


if __name__ == "__main__":
    # skip tests on python 3 for windows
    if not (os.name == "nt" and sys.version_info[0] == 3):
        from multiprocessing import freeze_support
        freeze_support()
        tables.test()
