#!/bin/bash
if [[ $target_platform =~ linux.* ]] || [[ $target_platform == win-32 ]] || [[ $target_platform == win-64 ]] || [[ $target_platform == osx-64 ]]; then
  export DISABLE_AUTOBREW=1

  if [[ $target_platform =~ linux.* ]]; then
    # force linking to libgfortran and not libgfortran-ng
    LIBGFORTRAN_PREFIX=$(jq -r ".extracted_package_dir" $PREFIX/conda-meta/libgfortran-3.*.json)
    LDFLAGS=$($R CMD CONFIG LDFLAGS | sed "s|$PREFIX/lib|$LIBGFORTRAN_PREFIX/lib|g")

    # cannot edit $SRC_DIR/src/Makevars.in as it will then fail a checksum
    mkdir -p ~/.R
    echo "LDFLAGS=$LDFLAGS" >> ~/.R/Makevars
  fi

  $R CMD INSTALL --build .
else
  mkdir -p $PREFIX/lib/R/library/RPostgres
  mv * $PREFIX/lib/R/library/RPostgres
fi
