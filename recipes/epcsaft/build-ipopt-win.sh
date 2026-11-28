#!/usr/bin/env bash
# Sourced by run_autotools_clang_conda_build; PREFIX is the private install prefix.
set -euo pipefail
: "${LIBRARY_PREFIX:?}" "${SRC_DIR:?}" "${PREFIX:?}" "${BUILD_PREFIX:?}"
[[ ${target_platform:?} == win-64 ]]
declare -F patch_libtool >/dev/null
source_dir=$(cygpath -u "$SRC_DIR")/ipopt-source
private_prefix=$(cygpath -m "$PREFIX")
library_prefix=$(cygpath -m "$LIBRARY_PREFIX")
evidence="$private_prefix/share/epcsaft-ipopt-probe"
mkdir -p "$evidence" "$source_dir/../ipopt-build"
for library in dmumps openblas; do
    test -f "$library_prefix/lib/$library.lib"
    printf '%s\n' "$library_prefix/lib/$library.lib"
done | tee "$evidence/link-inputs.txt"
FC="$(cygpath -u "$BUILD_PREFIX")/Library/bin/flang.exe"
export FC
test -x "$FC"
export F77="$FC"
# Autoconf misreads Flang's MSVC verbose link output as GNU libraries.
# Supply real libraries, while leaving its mixed-language link probes enabled.
build_library_prefix=$(cygpath -m "$BUILD_PREFIX")/Library/lib
export FLIBS="-L$build_library_prefix -lflang -lflangrti -lompstub"
export FFLAGS="-O2 $FLIBS -lflangmain -lmsvcrt -Xlinker /subsystem:console"
export CFLAGS="$CFLAGS -fno-fast-math -ffp-contract=off"
export CXXFLAGS="$CXXFLAGS -fno-fast-math -ffp-contract=off -Wno-reserved-user-defined-literal"
# Preserve forward slashes in configure-generated include flags.
export CYGPATH_W="cygpath -m"
export CPPFLAGS="$CPPFLAGS -I$library_prefix/include"
export LDFLAGS="$LDFLAGS -L$library_prefix/lib"
{
    "$CC" --version
    "$CXX" --version
    "$F77" --version
} > "$evidence/compilers.txt" 2>&1
cd "$source_dir/../ipopt-build"
build_dir=$PWD
# Copy in the shell: MSYS find -exec exceeds its Windows argument/environment limit.
retain_configuration() {
    cd "$build_dir"
    while IFS= read -r path; do
        cp --parents "$path" "$evidence"
    done < <(find . \( -name config.log -o -name 'config*.h' -o -name libtool -o -name '*.def' -o -name '*.exp' \) -print)
}
trap retain_configuration EXIT
# Native Windows make cannot resolve MSYS absolute /d source paths.
../ipopt-source/configure --prefix="$private_prefix" \
    --enable-shared --disable-static --disable-java --disable-sipopt \
    --disable-linear-solver-loader --without-hsl --without-asl \
    --disable-mpiinit --disable-pardisomkl --without-spral \
    --with-lapack-lflags=-lopenblas \
    --with-mumps-cflags="-I$library_prefix/include/mumps_seq" \
    --with-mumps-lflags=-ldmumps 2>&1 | tee "$evidence/configure.txt"
# Verify the COFF command before enabling the old libtool's unrecognized linker.
printf '%s\n' 'extern "C" __declspec(dllexport) int link_probe() { return 0; }' > "$evidence/link-probe.cpp"
# shellcheck disable=SC2086
nice -n 10 "$CXX" $CXXFLAGS "$evidence/link-probe.cpp" -o "$evidence/link-probe.dll" -Wl,-DLL 2>&1 | tee "$evidence/link-probe.txt"
test -s "$evidence/link-probe.dll"
# The wrapper recognizes .lib archives; this libtool uses .a convenience archives.
# Fail export generation immediately instead of allowing an empty DLL export list.
sed -i '2i set -e' "$source_dir/../create_def.sh"
# shellcheck disable=SC2016
sed -i 's/"$arg" == \*\.lib/"$arg" == *.lib || "$arg" == *.a/' "$source_dir/../create_def.sh"
# The conda wrapper supplies COFF C++ exports. Rename the DLL before linking:
# renaming an installed DLL alone leaves its old identity in the import library.
while IFS= read -r libtool; do
    (
        cd "$(dirname "$libtool")"
        patch_libtool
        # shellcheck disable=SC2016
        sed -i '3s/; echo/ \&\& echo/; s/\$CC -o/\$CC -fuse-ld=lld -nostdlib -Xclang --dependent-lib=msvcrt -o/; s/^build_libtool_libs=.*/build_libtool_libs=yes/; s/^build_old_libs=.*/build_old_libs=no/; s/^always_export_symbols=.*/always_export_symbols=yes/; s/\$tool_output_objdir/\$output_objdir\//g; s/^soname_spec=.*/soname_spec="epcsaft_ipopt_31420.dll"/; s/^library_names_spec=.*/library_names_spec="epcsaft_ipopt_31420.dll"/' libtool
    )
done < <(find "$PWD" -name libtool -type f)
JOBS=$("$BUILD_PREFIX/python.exe" "$RECIPE_DIR/build-jobs.py" ipopt)
nice -n 10 make -j"$JOBS" 2>&1 | tee "$evidence/make.txt"
# The MSYS pkg-config search path cannot contain a Windows drive colon.
make install PKG_CONFIG="env PKG_CONFIG_PATH=$(cygpath -u "$private_prefix")/lib/pkgconfig pkg-config" 2>&1 | tee "$evidence/install.txt"
mkdir -p "$private_prefix/lib/pkgconfig" "$private_prefix/bin"
dll="$PWD/src/.libs/epcsaft_ipopt_31420.dll"
test -f "$dll"
cp "$dll" "$private_prefix/bin/"
implib="$PWD/src/.libs/libipopt.dll.lib"
test -f "$implib"
cp "$implib" "$private_prefix/lib/epcsaft_ipopt_31420.lib"
cat > "$private_prefix/lib/pkgconfig/ipopt.pc" <<PC
prefix=\${pcfiledir}/../..
libdir=\${prefix}/lib
includedir=\${prefix}/include/coin-or
Name: Ipopt
Description: Private Ipopt 3.14.20 with MUMPS
Version: 3.14.20
Libs: -L\${libdir} -lepcsaft_ipopt_31420
Cflags: -I\${includedir}
PC
sha256sum "$private_prefix/bin/epcsaft_ipopt_31420.dll" \
    "$private_prefix/lib/epcsaft_ipopt_31420.lib" > "$evidence/sha256.txt"
llvm-readobj --coff-imports --coff-exports "$private_prefix/bin/epcsaft_ipopt_31420.dll" > "$evidence/dll.txt"
