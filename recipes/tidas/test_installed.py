
import tidas.test

# The serial tests should always run
tidas.test.run()

# The MPI import is already tested in meta.yaml if MPI builds
# are enabled.  Here we assume that if we can import it, then
# the build was enabled and the tests should pass.
try:
    import tidas.mpi
    tidas.test.run_mpi()
except ImportError:
    pass
