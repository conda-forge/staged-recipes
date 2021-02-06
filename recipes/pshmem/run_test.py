import os

# Disable MPI before import
os.environ["MPI_DISABLE"] = "1"

import pshmem.test

pshmem.test.run()
