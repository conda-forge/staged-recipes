#!/usr/bin/env bash
set -euxo pipefail

# Versioned subdir install ($PREFIX/PFUNIT-<x.y>/). Assert the CMake package config
# and the static libraries consumers link (-lpfunit -lfunit) landed, plus the .pf
# preprocessor consumers invoke. Building at all proves find_package resolved the
# gftl/gftl-shared/fargparse subdir installs and that MPI was found.
sub=$(echo "$PREFIX"/PFUNIT-*)
test -d "$sub/include"
test -f "$sub/cmake/PFUNITConfig.cmake"
ls "$sub"/lib*/libpfunit.a
ls "$sub"/lib*/libfunit.a
# The .pf preprocessor lands under the subdir's bin. Run it rather than just
# looking for it: that also checks its `funit` package came along and that the
# python run dependency satisfies its #!/usr/bin/env python shebang.
"$sub/bin/funitproc" --help
echo "pFUnit installed at: $sub"
echo PFUNIT_OK
