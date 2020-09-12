import jax
import jax.numpy as np
from mpi4py import MPI

print(MPI.get_vendor())

rank = MPI.COMM_WORLD.Get_rank()
size = MPI.COMM_WORLD.Get_size()

print("MPI rank = ", rank)
print("MPI size = ", size)

from mpi4jax import Allreduce

def test_allreduce():
    arr = np.ones((3, 2))
    _arr = arr.copy()

    res = Allreduce(arr, op=MPI.SUM)
    assert np.array_equal(res, arr * size)
    assert np.array_equal(_arr, arr)

    res = jax.jit(lambda x: Allreduce(x, op=MPI.SUM))(arr)
    assert np.array_equal(res, arr * size)
    assert np.array_equal(_arr, arr)

test_allreduce()