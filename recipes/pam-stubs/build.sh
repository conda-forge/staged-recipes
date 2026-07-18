#!/bin/bash

set -euxo pipefail

# ---------------------------------------------------------------------------
# pam-stubs: ship the Linux-PAM public headers plus a *link-time only* stub of
# libpam so that conda packages (e.g. weston's VNC backend) can compile and
# link against libpam, while the real authentication library is resolved from
# the user's system PAM (/lib*/libpam.so.0, driven by /etc/pam.d) at runtime.
#
# The stub .so is deliberately installed into $PREFIX/lib/stubs (a NON-runtime
# directory) and never into $PREFIX/lib, so it can never shadow the system
# libpam via the conda $ORIGIN/../lib rpath.
# ---------------------------------------------------------------------------

# --- 1. Install the public headers -----------------------------------------
mkdir -p "${PREFIX}/include/security"
cp -p libpam/include/security/pam_appl.h      "${PREFIX}/include/security/"
cp -p libpam/include/security/pam_modules.h   "${PREFIX}/include/security/"
cp -p libpam/include/security/pam_ext.h       "${PREFIX}/include/security/"
cp -p libpam/include/security/pam_modutil.h   "${PREFIX}/include/security/"
cp -p libpam/include/security/_pam_types.h    "${PREFIX}/include/security/"
cp -p libpam/include/security/_pam_compat.h   "${PREFIX}/include/security/"
cp -p libpam/include/security/_pam_macros.h   "${PREFIX}/include/security/"
# pam_misc.h is #included by weston's auth.c; it in turn pulls in pam_client.h.
cp -p libpamc/include/security/pam_client.h   "${PREFIX}/include/security/"
cp -p libpam_misc/include/security/pam_misc.h "${PREFIX}/include/security/"

# --- 2. Generate the stub sources -------------------------------------------
# Version script: reproduce the SONAME versions the real libpam exports so that
# downstream binaries record exactly the versioned symbol requirements
# (e.g. pam_start@LIBPAM_1.0) that the system libpam.so.0 satisfies.
cat > libpam-stub.map <<'MAP'
LIBPAM_1.0 {
  global:
    pam_start;
    pam_end;
    pam_authenticate;
    pam_setcred;
    pam_acct_mgmt;
    pam_open_session;
    pam_close_session;
    pam_chauthtok;
    pam_set_item;
    pam_get_item;
    pam_strerror;
    pam_putenv;
    pam_getenv;
    pam_getenvlist;
    pam_fail_delay;
  local:
    *;
};
LIBPAM_1.4 {
  global:
    pam_start_confdir;
} LIBPAM_1.0;
MAP

# The bodies are NEVER executed; they only need correct, ABI-compatible
# signatures (taken from the real headers) so downstreams link cleanly.
cat > libpam-stub.c <<'STUB'
#include <security/pam_appl.h>
#include <stddef.h>

int pam_start(const char *service_name, const char *user,
              const struct pam_conv *pam_conversation, pam_handle_t **pamh)
{ (void)service_name; (void)user; (void)pam_conversation; (void)pamh; return PAM_SYSTEM_ERR; }

int pam_start_confdir(const char *service_name, const char *user,
              const struct pam_conv *pam_conversation, const char *confdir,
              pam_handle_t **pamh)
{ (void)service_name; (void)user; (void)pam_conversation; (void)confdir; (void)pamh; return PAM_SYSTEM_ERR; }

int pam_end(pam_handle_t *pamh, int pam_status)
{ (void)pamh; (void)pam_status; return PAM_SYSTEM_ERR; }

int pam_authenticate(pam_handle_t *pamh, int flags)
{ (void)pamh; (void)flags; return PAM_SYSTEM_ERR; }

int pam_setcred(pam_handle_t *pamh, int flags)
{ (void)pamh; (void)flags; return PAM_SYSTEM_ERR; }

int pam_acct_mgmt(pam_handle_t *pamh, int flags)
{ (void)pamh; (void)flags; return PAM_SYSTEM_ERR; }

int pam_open_session(pam_handle_t *pamh, int flags)
{ (void)pamh; (void)flags; return PAM_SYSTEM_ERR; }

int pam_close_session(pam_handle_t *pamh, int flags)
{ (void)pamh; (void)flags; return PAM_SYSTEM_ERR; }

int pam_chauthtok(pam_handle_t *pamh, int flags)
{ (void)pamh; (void)flags; return PAM_SYSTEM_ERR; }

int pam_set_item(pam_handle_t *pamh, int item_type, const void *item)
{ (void)pamh; (void)item_type; (void)item; return PAM_SYSTEM_ERR; }

int pam_get_item(const pam_handle_t *pamh, int item_type, const void **item)
{ (void)pamh; (void)item_type; (void)item; return PAM_SYSTEM_ERR; }

const char *pam_strerror(pam_handle_t *pamh, int errnum)
{ (void)pamh; (void)errnum; return NULL; }

int pam_putenv(pam_handle_t *pamh, const char *name_value)
{ (void)pamh; (void)name_value; return PAM_SYSTEM_ERR; }

const char *pam_getenv(pam_handle_t *pamh, const char *name)
{ (void)pamh; (void)name; return NULL; }

char **pam_getenvlist(pam_handle_t *pamh)
{ (void)pamh; return NULL; }

int pam_fail_delay(pam_handle_t *pamh, unsigned int musec_delay)
{ (void)pamh; (void)musec_delay; return PAM_SYSTEM_ERR; }
STUB

# --- 3. Build the stub into the NON-runtime stubs/ directory ----------------
# Compiling against the just-installed headers also validates that they are
# self-consistent. SONAME is libpam.so.0 (matches the real library).
mkdir -p "${PREFIX}/lib/stubs"
${CC} ${CFLAGS} -shared -fPIC \
  -I"${PREFIX}/include" \
  -o "${PREFIX}/lib/stubs/libpam.so" \
  libpam-stub.c \
  -Wl,-soname,libpam.so.0 \
  -Wl,--version-script=libpam-stub.map

# --- 4. pkg-config file (meson's dependency('pam') finds this first) --------
# Libs points at the stubs dir so linking picks up the stub, not $PREFIX/lib.
mkdir -p "${PREFIX}/lib/pkgconfig"
cat > "${PREFIX}/lib/pkgconfig/pam.pc" <<PC
prefix=${PREFIX}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: pam
Description: Pluggable Authentication Modules (conda-forge link-time stub)
Version: ${PKG_VERSION}
Libs: -L\${libdir}/stubs -lpam
Cflags: -I\${includedir}
PC

# --- 5. Activation: make bare `-lpam` / meson cc.find_library('pam') work ---
# Add the stubs dir to LIBRARY_PATH, which gcc/clang consult ONLY at link time.
# LIBRARY_PATH never affects the runtime dynamic loader, so this cannot shadow
# the system libpam; it merely lets consumers that skip pkg-config still link.
for CHANGE in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
done

cat > "${PREFIX}/etc/conda/activate.d/pam-stubs.sh" <<'ACT'
export LIBRARY_PATH="${CONDA_PREFIX}/lib/stubs${LIBRARY_PATH:+:${LIBRARY_PATH}}"
ACT

cat > "${PREFIX}/etc/conda/deactivate.d/pam-stubs.sh" <<'DEACT'
if [ -n "${LIBRARY_PATH:-}" ]; then
  _pam_entry="${CONDA_PREFIX}/lib/stubs"
  _pam_wrapped=":${LIBRARY_PATH}:"
  _pam_wrapped="${_pam_wrapped//:${_pam_entry}:/:}"
  _pam_wrapped="${_pam_wrapped#:}"
  _pam_wrapped="${_pam_wrapped%:}"
  export LIBRARY_PATH="${_pam_wrapped}"
  unset _pam_entry _pam_wrapped
fi
DEACT
