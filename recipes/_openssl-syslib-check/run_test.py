import os
import subprocess
import shutil
import sys

# flush stdout after activation script
sys.stdout.flush()

PREFIX = os.environ['PREFIX']
LIBSSL_PATH = 'C:/Windows/System32/libssl-1_1-x64.dll'
LIBCRYPTO_PATH = 'C:/Windows/System32/libcrypto-1_1-x64.dll'

def run_activate():
    # always unset CONDA_DLL_SEARCH_MODIFICATION_ENABLE before testing a variant
    if 'CONDA_DLL_SEARCH_MODIFICATION_ENABLE' in os.environ:
        del os.environ['CONDA_DLL_SEARCH_MODIFICATION_ENABLE']

    has_cryptography = os.path.exists(PREFIX + r'\Lib\site-packages\cryptography')
    str_cryptography = has_cryptography * ', cryptography'
    str_ssl = os.path.exists(LIBSSL_PATH) * ', sys-libssl'
    str_crypto = os.path.exists(LIBCRYPTO_PATH) * ', sys-libcrypto'

    sys.stdout.flush()
    print('\nTesting activate.bat in presence of openssl'
          + str_cryptography + str_ssl + str_crypto, flush=True)
    # this is the path where activate.bat gets copied in bld.bat
    ret = subprocess.call([PREFIX + r'\etc\conda\activate.d\_openssl-syslib-check_activate.bat'])
    # make sure output of subprocess gets inserted into log at correct point
    sys.stdout.flush()
    if ret:
        raise AssertionError('activate.bat returned a non-zero return code!')

    # same for activate.sh
    if 'CONDA_DLL_SEARCH_MODIFICATION_ENABLE' in os.environ:
        del os.environ['CONDA_DLL_SEARCH_MODIFICATION_ENABLE']
    print('\nTesting activate.sh in presence of openssl'
          + str_cryptography + str_ssl + str_crypto + ' (using bash)', flush=True)
    ret = subprocess.call(['bash', PREFIX + r'\etc\conda\activate.d\_openssl-syslib-check_activate.sh'], shell=True)
    sys.stdout.flush()
    if ret:
        raise AssertionError('activate.sh returned a non-zero return code!')

# test with openssl & cryptography, but no syslibs (should have been deleted already, see
# github.com/conda-forge/conda-forge-ci-setup-feedstock/blob/2.x/recipe/run_conda_forge_build_setup_win.bat#L43-L49)
run_activate()

try:
    # move an outdated libssl to the system path
    shutil.copyfile('TESTING_ONLY_DO_NOT_USE/1.1.1d-libssl.dll', LIBSSL_PATH)
    run_activate()

    # also move an outdated libcrypto to the system path
    shutil.copyfile('TESTING_ONLY_DO_NOT_USE/1.1.1d-libcrypto.dll', LIBCRYPTO_PATH)
    run_activate()
except PermissionError:
    print('\nCould not test with outdated libssl/libcrypto on system path; no permission to copy there')

try:
    # remove cryptography, then test with only openssl & outdated libs
    shutil.rmtree(PREFIX + r'\Lib\site-packages\cryptography')
    run_activate()
except PermissionError:
    print('\nCould not test without cryptography; no permission to delete package')

try:
    # now delete the outdated libs again
    os.remove(LIBSSL_PATH)
    run_activate()

    # finally, with cryptography & openssl, but no syslibs
    os.remove(LIBCRYPTO_PATH)
    run_activate()
except (PermissionError, FileNotFoundError):
    pass
