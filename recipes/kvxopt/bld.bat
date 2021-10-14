

set KVXOPT_MSVC=1
:: the KVXOPT builder for suitesparse looks for static ".lib" libraries (not ".dll"!)
set "KVXOPT_BLAS_LIB_DIR=%LIBRARY_PREFIX%\lib"

:: build using netlib
set KVXOPT_BLAS_LIB=blas
set KVXOPT_LAPACK_LIB=lapack

set KVXOPT_BUILD_GSL=1
set "KVXOPT_GSL_LIB_DIR=%LIBRARY_PREFIX%\lib"
set "KVXOPT_GSL_INC_DIR=%LIBRARY_PREFIX%\include\gsl"

set KVXOPT_BUILD_FFTW=1
set "KVXOPT_FFTW_LIB_DIR=%LIBRARY_PREFIX%\lib"
set "KVXOPT_FFTW_INC_DIR=%LIBRARY_PREFIX%\include"

set KVXOPT_BUILD_GLPK=1
set "KVXOPT_GLPK_LIB_DIR=%LIBRARY_PREFIX%\lib"
set "KVXOPT_GLPK_INC_DIR=%LIBRARY_PREFIX%\include"

set KVXOPT_BUILD_DSDP=1
set "KVXOPT_DSDP_LIB_DIR=%LIBRARY_PREFIX%\lib"
set "KVXOPT_DSDP_INC_DIR=%LIBRARY_PREFIX%\include"

set KVXOPT_BUILD_OSQP=1
set "KVXOPT_OSQP_LIB_DIR=%LIBRARY_PREFIX%\lib"
set "KVXOPT_OSQP_INC_DIR=%LIBRARY_PREFIX%\include\osqp"

:: recipe/meta.yaml downloads the suitesparse-sources to this folder; build it
set "KVXOPT_SUITESPARSE_SRC_DIR=%SRC_DIR%\suitesparse"

%PYTHON% setup.py install --single-version-externally-managed --record=record.txt

copy src\C\cvxopt.h %LIBRARY_PREFIX%\include
