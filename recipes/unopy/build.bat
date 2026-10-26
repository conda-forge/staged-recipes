@echo on

cd /d "%SRC_DIR%" || exit 1

:: Force the Ninja generator and clear VS-specific generator fields set by
:: conda-forge's activation. The default "Visual Studio 17 2022" generator
:: does not support Fortran, which Uno requires for BLAS/LAPACK/MUMPS name
:: mangling (enable_language(Fortran) in CMakeLists.txt).
set "CMAKE_GENERATOR=Ninja"
set "CMAKE_GENERATOR_PLATFORM="
set "CMAKE_GENERATOR_TOOLSET="

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
:: which covers both BLAS and LAPACK; openblas is in host requirements
:: to bring it in.
::
:: Upstream's pyproject.toml sets BUILD_SHARED_LIBS=ON, which also installs
:: libuno and its headers (COMPONENT libuno) into site-packages. unopy
:: compiles the Uno objects directly, so install only the unopy extension.
::
:: Uno has no OpenMP code; USE_OPENMP only links an OpenMP runtime when MUMPS
:: is found, and FindOpenMP fails on the Fortran component with LLVM Flang,
:: so disable it.

%PYTHON% -m pip install . -vv ^
    --no-deps ^
    --no-build-isolation ^
    -C install.components=Unspecified ^
    -C cmake.define.BLAS_LIBRARIES="%LIBRARY_PREFIX%/lib/openblas.lib" ^
    -C cmake.define.LAPACK_LIBRARIES="%LIBRARY_PREFIX%/lib/openblas.lib" ^
    -C cmake.define.METIS_LIBRARY="%LIBRARY_PREFIX%/lib/metis.lib" ^
    -C cmake.define.MUMPS_LIBRARY="%LIBRARY_PREFIX%/lib/dmumps.lib" ^
    -C cmake.define.MUMPS_COMMON_LIBRARY="%LIBRARY_PREFIX%/lib/mumps_common.lib" ^
    -C cmake.define.MUMPS_PORD_LIBRARY="%LIBRARY_PREFIX%/lib/pord.lib" ^
    -C cmake.define.MUMPS_MPISEQ_LIBRARY="%LIBRARY_PREFIX%/lib/mumps_common.lib" ^
    -C cmake.define.MUMPS_INCLUDE_DIR="%LIBRARY_PREFIX%/include;%LIBRARY_PREFIX%/include/mumps_seq" ^
    -C cmake.define.USE_OPENMP=OFF ^
    -C cmake.define.BQPD="" ^
    -C cmake.define.SPRAL="" ^
    -C cmake.define.HIGHS="%LIBRARY_PREFIX%/lib/highs.lib" ^
    -C cmake.define.HIGHS_INCLUDE_DIR="%LIBRARY_PREFIX%/include/highs"
if errorlevel 1 exit 1
