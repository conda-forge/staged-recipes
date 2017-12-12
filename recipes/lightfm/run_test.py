import os
import sys
import pkgutil
from subprocess import check_call

if os.name == 'posix':
    # linux only
    package = pkgutil.get_loader("lightfm")
    if hasattr(package, "filename"):
        package_filename = package.filename
    else:
        package_filename = os.path.dirname(package.path)

    modules = os.listdir(package_filename)
    print('Installed modules:')
    print(modules)
    module_so = [key for key in modules if key.endswith('.so')][0]
    print('ldd ', module_so)
    check_call(['ldd', os.path.join(package_filename, module_so)])
    print('Attempting to import')
    sys.path.append(package_filename)
    import _lightfm_fast_openmp
