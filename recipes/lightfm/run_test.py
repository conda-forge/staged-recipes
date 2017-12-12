import os
import sys
import pkgutil
import traceback
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
    print('\nldd ' + module_so)
    check_call(['ldd', os.path.join(package_filename, module_so)])

    print('\nAttempting to import _lightfm_fast_openmp')
    sys.path.append(package_filename)
    try:
        import _lightfm_fast_openmp
    except Exception as e:
        print('--- Beging tracback ---')
        print(e)
        if sys.version_info > (3, 0):
            traceback.print_tb(e.__traceback__)
        else:
            traceback.print_exc()
        print('--- End tracback ---')
