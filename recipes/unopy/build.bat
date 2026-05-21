@echo on

cd /d "%SRC_DIR%" || exit 1

:: conda-forge's mumps-seq on Windows splits headers between
:: %LIBRARY_PREFIX%/include (dmumps_c.h) and
:: %LIBRARY_PREFIX%/include/mumps_seq (dummy mpi.h). Pass both via
:: MUMPS_INCLUDE_DIR as a CMake list (semicolon-separated).
::
:: Windows mumps-seq does not ship a separate mpiseq import library; the
:: dummy MPI symbols are merged into mumps_common.lib. Point
:: MUMPS_MPISEQ_LIBRARY at mumps_common.lib so Uno's CMakeLists picks the
:: sequential branch (CMake dedupes the duplicate entry on the link line).
::
:: Conda-forge libblas/liblapack on Windows ship only runtime DLLs, no
:: import libraries. The openblas package provides Library/lib/openblas.lib
:: which covers both BLAS and LAPACK; blas-devel is in host requirements
:: to bring it in.
::
:: BQPD is overridden to empty to neutralize the vendored-dep default in
:: upstream's pyproject.toml. HIGHS is pointed at the conda-forge highs
:: package.
%PYTHON% -m pip install . -vv ^
    --no-deps ^
    --no-build-isolation ^
    -C cmake.define.BLAS_LIBRARIES="%LIBRARY_PREFIX%/lib/openblas.lib" ^
    -C cmake.define.LAPACK_LIBRARIES="%LIBRARY_PREFIX%/lib/openblas.lib" ^
    -C cmake.define.METIS_LIBRARY="%LIBRARY_PREFIX%/lib/metis.lib" ^
    -C cmake.define.MUMPS_LIBRARY="%LIBRARY_PREFIX%/lib/dmumps.lib" ^
    -C cmake.define.MUMPS_COMMON_LIBRARY="%LIBRARY_PREFIX%/lib/mumps_common.lib" ^
    -C cmake.define.MUMPS_PORD_LIBRARY="%LIBRARY_PREFIX%/lib/pord.lib" ^
    -C cmake.define.MUMPS_MPISEQ_LIBRARY="%LIBRARY_PREFIX%/lib/mumps_common.lib" ^
    -C cmake.define.MUMPS_INCLUDE_DIR="%LIBRARY_PREFIX%/include;%LIBRARY_PREFIX%/include/mumps_seq" ^
    -C cmake.define.BQPD="" ^
    -C cmake.define.HIGHS="%LIBRARY_PREFIX%/lib/highs.lib"
if errorlevel 1 exit 1
