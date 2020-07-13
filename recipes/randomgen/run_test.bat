set NUMBER_OF_PROCESSORS=1
set MKL_NUM_THREADS=1
set NUMEXPR_NUM_THREADS=1
set OMP_NUM_THREADS=1
set OPENBLAS_NUM_THREADS=1
set MPLBACKEND=agg

python -c "import randomgen; randomgen.test(['--skip-slow'])"