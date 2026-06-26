#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -o xtrace

# This output inherits the fully built (blind) tree from the staging cache at
# ${PREFIX}/share/calchep. Here we only finalize it: fix the recorded run-time
# compiler, expose the user-facing tools on PATH, and ship activation scripts.
CALCHEP_HOME="${PREFIX}/share/calchep"

# Platform branch: the run-time JIT compiler is gcc on Linux and clang on macOS
# (matching upstream getFlags), ranlib needs -c on macOS, and the per-binary rpath
# token is $ORIGIN on Linux vs @loader_path on macOS.
case "${target_platform:-}" in
  osx-*) is_osx=1 ;;
  "")    [ "$(uname -s)" = Darwin ] && is_osx=1 || is_osx=0 ;;
  *)     is_osx=0 ;;
esac
if [ "${is_osx}" = 1 ]; then
  _CC=clang; _CXX=clang++; _RANLIB="ranlib -c"; _ORIGIN="@loader_path"
else
  _CC=gcc;   _CXX=g++;     _RANLIB="ranlib";    _ORIGIN="'\$ORIGIN'"
fi

# Record portable, bare compiler names for the run-time JIT compilation step.
# The build-time conda compiler (e.g. x86_64-conda-linux-gnu-cc) does not exist
# at run time, and its build-only CFLAGS (sysroot, -fdebug-prefix-map, ...) would
# be wrong there too. Reset to CalcHEP's portable defaults; the bare gcc (Linux) /
# clang (macOS) is a package run dependency (see recipe.yaml), so the run-time JIT
# always has a compiler. -fcommon is kept for the same reason it is needed at build
# time. SNUM/SO/lDL/lFort/lQuad determined by getFlags are left
# untouched so run-time compilation matches the shipped libraries. The
# -Wno-error=* flags keep on-demand process compilation working on the user's
# GCC >= 14 (which errors on the same legacy-C constructs as at build time).
LEGACY_C="-Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types -Wno-error=int-conversion -Wno-error=implicit-int"
sed -i -E \
  -e "s|^CC=.*|CC=\"${_CC}\"|" \
  -e "s|^CXX=.*|CXX=\"${_CXX}\"|" \
  -e 's|^FC=.*|FC="gfortran"|' \
  -e "s|^CFLAGS=.*|CFLAGS=\"-g -fsigned-char -std=gnu99 -fPIC -fcommon ${LEGACY_C}\"|" \
  -e 's|^CXXFLAGS=.*|CXXFLAGS="-g -fPIC -fcommon"|' \
  -e 's|^FFLAGS=.*|FFLAGS="-fno-automatic"|' \
  -e "s|^RANLIB=.*|RANLIB=\"${_RANLIB}\"|" \
  "${CALCHEP_HOME}/FlagsForSh"
sed -i -E \
  -e "s|^CC = .*|CC = ${_CC}|" \
  -e "s|^CXX=.*|CXX=${_CXX}|" \
  -e 's|^FC = .*|FC = gfortran|' \
  -e "s|^CFLAGS = .*|CFLAGS = -g -fsigned-char -std=gnu99 -fPIC -fcommon ${LEGACY_C}|" \
  -e 's|^CXXFLAGS = .*|CXXFLAGS = -g -fPIC -fcommon|' \
  -e 's|^FFLAGS = .*|FFLAGS = -fno-automatic|' \
  -e "s|^RANLIB = .*|RANLIB = ${_RANLIB}|" \
  "${CALCHEP_HOME}/FlagsForMake"

# Make the bundled Perl scripts (e.g. bin/run_batch, reached from a work dir via
# its bin -> $CALCHEP/bin symlink) portable: rewrite the hard-coded
# ``#!/usr/bin/perl`` shebang to an env-based one so they resolve perl from the
# active environment (the ``perl`` run dependency) instead of a fixed system
# path. conda does not rewrite this automatically (it is not a prefix path).
while IFS= read -r script; do
  sed -i '1s@^#![[:space:]]*/usr/bin/perl@#!/usr/bin/env perl@' "${script}"
done < <(grep -rlE '^#![[:space:]]*/usr/bin/perl' "${CALCHEP_HOME}" 2>/dev/null || true)

# CalcHEP's shell scripts use the historical Bourne convention of a bare ":"
# first line instead of a "#!" shebang, and sbin/setPath re-bakes that ":" into
# several of them (mkWORKdir, bin/mkLibstat, ...). A script with no shebang cannot
# be exec'd directly -- it fails with ENOEXEC ("Exec format error") under strict
# launchers such as pixi's task shell (deno), even though /bin/sh-based callers
# (system(), bash) silently fall back to sh. Give every such script (they are all
# Bourne) a real "#!/bin/sh". Binaries are excluded via grep -I; perl scripts
# (rewritten above) start with "#!" so they do not match.
while IFS= read -r -d '' script; do
  head -1 "${script}" | grep -qxE ':[[:space:]]*' \
    && sed -i '1s|^:[[:space:]]*$|#!/bin/sh|' "${script}"
done < <(grep -rlIZE '^:[[:space:]]*$' "${CALCHEP_HOME}" 2>/dev/null || true)

# mkWORKdir additionally writes a ":" header for the per-work-dir launcher scripts
# it generates (./calchep, ./calchep_batch); emit "#!/bin/sh" instead so those are
# directly executable too. Their cat'd bodies are /bin/sh; run_batch (perl) keeps
# its own env shebang.
sed -i 's|^echo ":|echo "#!/bin/sh|' "${CALCHEP_HOME}/mkWORKdir"

# When CalcHEP builds a process's n_calchep at run time, sbin/ld_n links it
# against the per-process lf*.so libraries sitting beside it and relies on
# LD_RUN_PATH="$PWD" to record that directory as the rpath. But the conda-forge
# gcc wrapper injects its own -Wl,-rpath,$CONDA_PREFIX/lib, and an explicit
# -rpath makes the linker ignore LD_RUN_PATH -- so n_calchep ends up unable to
# load its sibling lf*.so ("cannot open shared object file"). Add an explicit
# $ORIGIN (Linux) / @loader_path (macOS) rpath so n_calchep always finds the
# libraries next to itself. (Delimiter is | not @: the macOS @loader_path value
# contains @, which would prematurely close an s@...@...@ expression.)
sed -i "s| -o n_calchep| -Wl,-rpath,${_ORIGIN} -o n_calchep|" "${CALCHEP_HOME}/sbin/ld_n"

# Link the run-time numerical executables against the combined shared library
# (libcalchep.so, produced by the staging build) instead of the individual static
# archives: replace num_c.a with -lcalchep + an rpath to $CALCHEP/lib (so the
# freshly built n_calchep finds it), and drop the other core archives now subsumed
# by the .so. -Wl,--allow-shlib-undefined is required because the combined .so also
# contains CalcHEP's optional-feature objects (the LHAPDF interface sf_lha.o and the
# Fortran-SLHA bridge fortran.o) whose external symbols (evolvePDFm, fortranreadline_,
# ...) are absent unless those features are used; they resolve lazily at run time only
# if exercised (otherwise dead). dummy.a stays static and last (overridable user
# stubs), as does dynamic_vp.a (the model-table storage that must NOT enter the .so;
# bin/make_main is its only consumer -- see build_cache.sh); sqme_aux.so and the
# per-process lib_0.a/ld*.a/lf*.so are untouched.
# -rdynamic stays so the dlopen'd lf*.so resolve callbacks against n_calchep + the
# (global) libcalchep.so. sbin/ld_n uses $cLib; bin/make_main uses $lib.
sed -i -E \
  -e 's@\$cLib/num_c\.a@-L$cLib -Wl,-rpath,$cLib -Wl,--allow-shlib-undefined -lcalchep@' \
  -e 's@\$cLib/(ntools|dynamic_me|libSLHAplus|serv)\.a@@g' \
  "${CALCHEP_HOME}/sbin/ld_n"
sed -i -E \
  -e 's@\$lib/num_c\.a@-L$lib -Wl,-rpath,$lib -Wl,--allow-shlib-undefined -lcalchep@' \
  -e 's@\$lib/(ntools|dynamic_me|libSLHAplus|serv)\.a@@g' \
  "${CALCHEP_HOME}/bin/make_main"

# macOS ld64 spelling of the consumer-link allow-undefined flag (mirrors the
# build_cache.sh translation for VandP.so): GNU's --allow-shlib-undefined ->
# Darwin's -undefined dynamic_lookup, applied to the run-time linker scripts.
if [ "${is_osx}" = 1 ]; then
  sed -i 's/-Wl,--allow-shlib-undefined/-Wl,-undefined,dynamic_lookup/g' \
    "${CALCHEP_HOME}/sbin/ld_n" "${CALCHEP_HOME}/bin/make_main"
fi

# Ship the shared library; drop the now-redundant static archives. Keep dummy.a
# (static overridable stubs), dynamic_vp.a (model-table storage; bin/make_main links
# it at run time -- it must not be folded into the .so, see build_cache.sh) and
# sqme_aux.so. symb.a is build-time only (the s_calchep / make_VandP / makeVrtLib
# binaries are already linked and never relink at run time); servNoX11.a is a
# micrOMEGAs-only variant (the blind engine uses serv).
rm -f "${CALCHEP_HOME}/lib/"{num_c,ntools,dynamic_me,libSLHAplus,serv,servNoX11,symb}.a

# libcalchep.so deliberately stays under share/calchep/lib and is NOT symlinked
# into ${PREFIX}/lib. CalcHEP is run-in-place: every binary it JIT-builds finds
# the library through an absolute rpath to $CALCHEP/lib (the -Wl,-rpath baked in
# by the ld_n/make_main edits above), never via the default loader path.
# Downstream consumers (e.g. micrOMEGAs) are CalcHEP-aware and link against
# $CALCHEP/lib the same way, so they do not need it in ${PREFIX}/lib either.
# Keeping this generically-named, unversioned .so out of the global lib dir also
# avoids polluting every environment's library namespace.

# Expose the user-facing tools via relative (relocatable) symlinks under their
# upstream names. Internal JIT helpers (make_main, mkLibstat, mkLibshared,
# subproc_cycle, make_VandP, Int) and the work-dir-internal ``calc`` are
# intentionally not exposed; they remain reachable via ${CALCHEP}/bin.
mkdir -p "${PREFIX}/bin"
ln -s "../share/calchep/mkWORKdir" "${PREFIX}/bin/mkWORKdir"
for tool in s_calchep event2lhe events2tab lhe2tab event_mixer \
            show_distr sum_distr lhapdf2pdt; do
  ln -s "../share/calchep/bin/${tool}" "${PREFIX}/bin/${tool}"
done

# Activation scripts (bash/POSIX, csh, fish) export CALCHEP so the engine and
# downstream packages (e.g. micrOMEGAs) can locate the installation, and so the
# binaries that consult getenv("CALCHEP") are robust against any relocation edge
# case.
for stage in activate deactivate; do
  mkdir -p "${PREFIX}/etc/conda/${stage}.d"
  for ext in sh csh fish; do
    cp "${RECIPE_DIR}/${stage}.${ext}" \
       "${PREFIX}/etc/conda/${stage}.d/calchep_${stage}.${ext}"
  done
done
