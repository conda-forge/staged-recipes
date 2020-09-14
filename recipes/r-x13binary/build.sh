#!/bin/bash

set -o errexit -o pipefail

if [[ ${target_platform} =~ linux.* ]] || [[ ${target_platform} == win-32 ]] || [[ ${target_platform} == win-64 ]] || [[ ${target_platform} == osx-64 ]]; then
  export DISABLE_AUTOBREW=1
  mv DESCRIPTION DESCRIPTION.old
  grep -va '^Priority: ' DESCRIPTION.old > DESCRIPTION
  ${R} CMD INSTALL --build .
else
  mkdir -p "${PREFIX}"/lib/R/library/x13binary
  mv ./* "${PREFIX}"/lib/R/library/x13binary


# Use our libgcc_s.1.dylib
#if [[ $target_platform == osx-64 ]]; then
#  pushd "${PREFIX}"
#    for SHARED_LIB in lib/R/library/x13binary/lib/libquadmath.0.dylib lib/R/library/x13binary/lib/libgfortran.3.dylib; do
#      install_name_tool -change "@executable_path/../lib/libgcc_s.1.dylib" "${PREFIX}/lib/libgcc_s.1.dylib" ${SHARED_LIB}
#    done
#    rm lib/R/library/x13binary/lib/libgcc_s.1.dylib

  # .. and our libquadmath.0.dylib and libgfortran.3.dylib
#  pushd "${PREFIX}"
#    for EXE in lib/R/library/x13binary/bin/x13ashtml; do
#      install_name_tool -change "@executable_path/../lib/libgcc_s.1.dylib" "${PREFIX}/lib/libgcc_s.1.dylib" ${EXE}
#      install_name_tool -change "@executable_path/../lib/libgfortran.3.dylib" "${PREFIX}/lib/libgfortran.3.dylib" ${EXE}
#      install_name_tool -change "@executable_path/../lib/libquadmath.0.dylib" "${PREFIX}/lib/libquadmath.0.dylib" ${EXE}
#    done
#    rm lib/R/library/x13binary/lib/libquadmath.0.dylib
#    rm lib/R/library/x13binary/lib/libgcc_s.1.dylib
#  popd
#fi





  if [[ ${target_platform} == osx-64 ]]; then
    pushd $PREFIX
      rm lib/R/library/x13binary/lib/libquadmath.0.dylib
      rm lib/R/library/x13binary/lib/libgcc_s.1.dylib
      for libdir in lib/R/lib lib/R/modules lib/R/library lib/R/bin/exec sysroot/usr/lib; do
        pushd $libdir || exit 1
          for SHARED_LIB in $(find . -type f -iname "*.dylib" -or -iname "*.so" -or -iname "R"); do
            echo "fixing SHARED_LIB $SHARED_LIB"
            install_name_tool -change /Library/Frameworks/R.framework/Versions/3.5.0-MRO/Resources/lib/libR.dylib "$PREFIX"/lib/R/lib/libR.dylib $SHARED_LIB || true
            install_name_tool -change /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libR.dylib "$PREFIX"/lib/R/lib/libR.dylib $SHARED_LIB || true
            install_name_tool -change /usr/local/clang4/lib/libomp.dylib "$PREFIX"/lib/libomp.dylib $SHARED_LIB || true
            install_name_tool -change /usr/local/gfortran/lib/libgfortran.3.dylib "$PREFIX"/lib/libgfortran.3.dylib $SHARED_LIB || true
            install_name_tool -change /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libquadmath.0.dylib "$PREFIX"/lib/libquadmath.0.dylib $SHARED_LIB || true
            install_name_tool -change /usr/local/gfortran/lib/libquadmath.0.dylib "$PREFIX"/lib/libquadmath.0.dylib $SHARED_LIB || true
            install_name_tool -change /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libgfortran.3.dylib "$PREFIX"/lib/libgfortran.3.dylib $SHARED_LIB || true
            install_name_tool -change /usr/lib/libgcc_s.1.dylib "$PREFIX"/lib/libgcc_s.1.dylib $SHARED_LIB || true
            install_name_tool -change /usr/lib/libiconv.2.dylib "$PREFIX"/sysroot/usr/lib/libiconv.2.dylib $SHARED_LIB || true
            install_name_tool -change /usr/lib/libncurses.5.4.dylib "$PREFIX"/sysroot/usr/lib/libncurses.5.4.dylib $SHARED_LIB || true
            install_name_tool -change /usr/lib/libicucore.A.dylib "$PREFIX"/sysroot/usr/lib/libicucore.A.dylib $SHARED_LIB || true
            install_name_tool -change /usr/lib/libexpat.1.dylib "$PREFIX"/lib/libexpat.1.dylib $SHARED_LIB || true
            install_name_tool -change /usr/lib/libcurl.4.dylib "$PREFIX"/lib/libcurl.4.dylib $SHARED_LIB || true
            install_name_tool -change /usr/lib/libc++.1.dylib "$PREFIX"/lib/libc++.1.dylib $SHARED_LIB || true
            install_name_tool -change /Library/Frameworks/R.framework/Versions/3.5/Resources/lib/libc++.1.dylib "$PREFIX"/lib/libc++.1.dylib $SHARED_LIB || true
          done
        popd
      done
    popd
  fi
fi
