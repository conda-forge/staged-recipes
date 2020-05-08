#!/bin/bash

# Check whether there are dlls for openssl on the system path that would gets
# picked up by the windows loader before those in the conda environment.
# If yes, warn that the environment is potentially vulnerable.

# early out for users who want to silence the warning
if [ -z $CONDA_SKIP_OPENSSL_DLL_CHECK ]; then
  exit 0
fi

LIBSSL_PATH=/c/Windows/System32/libssl-1_1-x64.dll
LIBCRYPTO_PATH=/c/Windows/System32/libcrypto-1_1-x64.dll

HAS_SYS_LIBS=F
HAS_SYS_SSL=F
HAS_SYS_CRYPTO=F
if [ -f "$LIBSSL_PATH" ]; then
  HAS_SYS_LIBS=T
  HAS_SYS_SSL=T
fi
if [ -f "$LIBCRYPTO_PATH" ]; then
  HAS_SYS_LIBS=T
  HAS_SYS_CRYPTO=T
fi

# early exit in case no syslibs are found
if [ $HAS_SYS_LIBS == "T" ]; then
    exit 0
fi

# if we made it until here, we need to detect if cryptography is installed
python -c "import cryptography" 2>/dev/null && HAS_CRYPTOGRAPHY=T || HAS_CRYPTOGRAPHY=F

if [ $HAS_SYS_LIBS == "T" ]; then
                                      echo "WARNING: Your system contains (potentially) outdated libraries under:"
  if [ $HAS_SYS_SSL == "T" ];    then echo "WARNING: $LIBSSL_PATH"; fi
  if [ $HAS_SYS_CRYPTO == "T" ]; then echo "WARNING: $LIBCRYPTO_PATH"; fi
                                      echo "WARNING: These DLLs will be linked to before those in the conda"
                                      echo "WARNING: environment and might make your installation vulnerable!"
fi

# If there is no python (resp. cryptography), we can only warn, since if anything wants to load
# openssl *from outside of python*, not even CONDA_DLL_SEARCH_MODIFICATION_ENABLE will help.
if [ $HAS_CRYPTOGRAPHY == "F" ]; then
                                      echo "WARNING: Your system contains (potentially) outdated libraries under:"
  if [ $HAS_SYS_SSL == "T" ];    then echo "WARNING: $LIBSSL_PATH"; fi
  if [ $HAS_SYS_CRYPTO == "T" ]; then echo "WARNING: $LIBCRYPTO_PATH"; fi
                                      echo "WARNING: These libraries will be linked before those in the conda"
                                      echo "WARNING: environment and might make your installation vulnerable!"
                                      echo "Info:    (You can silence this warning by setting the environment"
                                      echo "Info:    variable CONDA_SKIP_OPENSSL_DLL_CHECK to any value.)"
                                      exit 0
fi

# Now we detect if the openssl-version in the conda environment matches the one that
# cryptography loads (using the windows loader). For the latter, we want the full version
# text (with format "OpenSSL 1.1.[01][a-z]  dd MMM yyyy"), as well as the version itself;
# this is the second token after separating on spaces (counting from 0).
LINKED_VERSION_TEXT=$(python -c "from cryptography.hazmat.backends.openssl import backend; print(backend.openssl_version_text())")
LINKED_VERSION=${LINKED_VERSION_TEXT[1]}

# There are cases when even within the environment, `openssl version` will pick up the
# wrong version (e.g. possibly if git is installed in the environment). Therefore we take
# the information from conda itself. By the structure of the output from `conda list`,
# we need the second token again.
ENV_VERSION=$(conda list | grep "^openssl")
ENV_VERSION=${ENV_VERSION[1]}

# determine if syslib is outdated; reuse python for proper string ordering
LINKED_TO_OUTDATED_SYSLIB=$(python -c "print('$LINKED_VERSION' < '$ENV_VERSION')")

if [ $LINKED_TO_OUTDATED_SYSLIB == "True" ]; then
  # If an older syslib is used even with CONDA_DLL_SEARCH_MODIFICATION_ENABLE
  # already set, there's nothing more we can do than to warn the user.
  if [ -z $CONDA_DLL_SEARCH_MODIFICATION_ENABLE ]; then
                                        echo "WARNING: Your system contains outdated libraries under:"
    if [ $HAS_SYS_SSL == "T" ];    then echo "WARNING: $LIBSSL_PATH"; fi
    if [ $HAS_SYS_CRYPTO == "T" ]; then echo "WARNING: $LIBCRYPTO_PATH"; fi
                                        echo "WARNING: using '$LINKED_VERSION_TEXT' (instead of $ENV_VERSION in the env)."
                                        echo "WARNING: These DLLs will be preferred over those in the conda env (despite"
                                        echo "WARNING: our best tries), and might make your installation vulnerable!"
                                        echo "Info:    (Upgrading your python version should enable conda to work around"
                                        echo "Info:    this; alternatively, you can silence this warning by setting the"
                                        echo "Info:    environment variable CONDA_SKIP_OPENSSL_DLL_CHECK to any value.)"
  else
    # Otherwise, we set CONDA_DLL_SEARCH_MODIFICATION_ENABLE and try again.
    echo "Warning: Found outdated libssl/libcrypto DLLs on system;"
    echo "Warning: Attempting to re-activate with CONDA_DLL_SEARCH_MODIFICATION_ENABLE"
    echo
    export CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1
    # now we want to re-exec ourselves (cf. where activation is installed in bld.bat)
    exec $PREFIX/etc/conda/activate.d/_openssl-syslib-check_activate.sh || exit 1
  fi
else
  # If the correct version is linked because of CONDA_DLL_SEARCH_MODIFICATION_ENABLE,
  # still emit a warning that linking to libssl & libcrypto might be vulnerable.
  if [ -z $CONDA_DLL_SEARCH_MODIFICATION_ENABLE ]; then
                                        echo "WARNING: Your system contains outdated libraries under:"
    if [ $HAS_SYS_SSL == "T" ];    then echo "WARNING: $LIBSSL_PATH"; fi
    if [ $HAS_SYS_CRYPTO == "T" ]; then echo "WARNING: $LIBCRYPTO_PATH"; fi
                                        echo "WARNING: Within this environment, the python-runtime will correctly load"
                                        echo "WARNING: the openssl version of the environment, but be aware that anything"
                                        echo "WARNING: *outside* of python that is trying to load libssl/libcrypto will"
                                        echo "Warning: load the DLLs above, which might make that application vulnerable!"
                                        echo "Info:    (You can silence this warning by setting the environment"
                                        echo "Info:    variable CONDA_SKIP_OPENSSL_DLL_CHECK to any value.)"
fi
