import os
import subprocess
import shutil
import sys

# flush stdout after activation script
sys.stdout.flush()

LIBSSL_PATH = 'C:/Windows/System32/libssl-1_1-x64.dll'
LIBCRYPTO_PATH = 'C:/Windows/System32/libcrypto-1_1-x64.dll'

# the environment variables from the build stage are not available anymore;
# we reconstruct %PREFIX% from the path of the python runtime
PREFIX = sys.executable[:-len(r'\python.exe')]

def run_activate(has_cryptography):
    # always unset CONDA_DLL_SEARCH_MODIFICATION_ENABLE before testing a variant
    if 'CONDA_DLL_SEARCH_MODIFICATION_ENABLE' in os.environ:
        del os.environ['CONDA_DLL_SEARCH_MODIFICATION_ENABLE']

    str_ssl = os.path.exists(LIBSSL_PATH) * ', sys-libssl'
    str_crypto = os.path.exists(LIBCRYPTO_PATH) * ', sys-libcrypto'
    str_cryptography = has_cryptography * ', cryptography'

    sys.stdout.flush()
    print('\nTesting activate.bat in presence of openssl'
          + str_cryptography + str_ssl + str_crypto, flush=True)
    # this is the path where activate.{bat|sh} gets copied in bld.bat
    ret = subprocess.call([PREFIX + r'\etc\conda\activate.d\_openssl-syslib-check_activate.bat'])
    # make sure output of subprocess gets inserted into log at correct point
    sys.stdout.flush()
    if ret:
        raise AssertionError('activate.bat returned a non-zero return code!')

    # same for activate.sh
    if 'CONDA_DLL_SEARCH_MODIFICATION_ENABLE' in os.environ:
        del os.environ['CONDA_DLL_SEARCH_MODIFICATION_ENABLE']
    # TODO: add bash scripts
    # print('\nTesting activate.sh in presence of openssl'
    #       + str_cryptography + str_ssl + str_crypto + ' (using git-bash)', flush=True)
    # ret = subprocess.call([PREFIX + r'\Library\bin\bash.exe '  # don't forget space
    #                        + PREFIX + r'\etc\conda\activate.d\_openssl-syslib-check_activate.sh'])
    # sys.stdout.flush()
    # if ret:
    #     raise AssertionError('activate.sh returned a non-zero return code!')

# test with openssl & cryptography, but no syslibs (should have been deleted already, see
# github.com/conda-forge/conda-forge-ci-setup-feedstock/blob/2.x/recipe/run_conda_forge_build_setup_win.bat#L43-L49)
run_activate(has_cryptography=True)

try:
    # move an outdated libssl to the system path
    shutil.copyfile('TESTING_ONLY_DO_NOT_USE/1.1.1d-libssl.dll', LIBSSL_PATH)
    run_activate(has_cryptography=True)

    # also move an outdated libcrypto to the system path
    shutil.copyfile('TESTING_ONLY_DO_NOT_USE/1.1.1d-libcrypto.dll', LIBCRYPTO_PATH)
    run_activate(has_cryptography=True)
except PermissionError:
    print('\nCould not test with outdated libssl/libcrypto on system path; no permission to copy there')

# remove cryptography, then test with only openssl & outdated libs
shutil.rmtree(PREFIX + r'\Lib\site-packages\cryptography')
run_activate(has_cryptography=False)

try:
    # now delete the outdated libs again
    os.remove(LIBSSL_PATH)
    run_activate(has_cryptography=False)

    # finally, with cryptography & openssl, but no syslibs
    os.remove(LIBCRYPTO_PATH)
    run_activate(has_cryptography=False)
except (PermissionError, FileNotFoundError):
    pass
